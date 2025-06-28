#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install OpenVPN
apt-get install -y openvpn easy-rsa iptables-persistent

# Setup Easy-RSA
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa

# Configure Easy-RSA vars
cat > vars << EOF
set_var EASYRSA_ALGO "ec"
set_var EASYRSA_CURVE "secp384r1"
set_var EASYRSA_REQ_COUNTRY "US"
set_var EASYRSA_REQ_PROVINCE "State"
set_var EASYRSA_REQ_CITY "City"
set_var EASYRSA_REQ_ORG "Pentest-VPN"
set_var EASYRSA_REQ_EMAIL "admin@pentest.local"
set_var EASYRSA_REQ_OU "Security"
set_var EASYRSA_CA_EXPIRE 3650
set_var EASYRSA_CERT_EXPIRE 3650
EOF

# Initialize PKI
./easyrsa init-pki
echo "pentest-vpn-ca" | ./easyrsa build-ca nopass

# Generate server certificate
./easyrsa gen-req server nopass
./easyrsa sign-req server server

# Generate DH params
./easyrsa gen-dh

# Generate ta.key
openvpn --genkey --secret /etc/openvpn/ta.key

# Copy certificates
cp pki/ca.crt /etc/openvpn/
cp pki/issued/server.crt /etc/openvpn/
cp pki/private/server.key /etc/openvpn/
cp pki/dh.pem /etc/openvpn/

# Configure OpenVPN server
cat > /etc/openvpn/server.conf << EOF
port ${vpn_port}
proto ${vpn_protocol}
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
server ${vpn_network} ${vpn_subnet_mask}
ifconfig-pool-persist /var/log/openvpn/ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS ${dns_servers}"
keepalive 10 120
tls-auth ta.key 0
cipher AES-256-GCM
auth SHA256
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
verb 3
explicit-exit-notify 1
EOF

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Configure iptables
iptables -t nat -A POSTROUTING -s ${vpn_network}/${vpn_subnet_mask} -o eth0 -j MASQUERADE
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Save iptables rules
netfilter-persistent save

# Create client certificate generation script
cat > /root/generate-client.sh << 'EOSCRIPT'
#!/bin/bash
CLIENT_NAME=$1
if [ -z "$CLIENT_NAME" ]; then
    echo "Usage: $0 <client-name>"
    exit 1
fi

cd /etc/openvpn/easy-rsa
./easyrsa gen-req "$CLIENT_NAME" nopass
./easyrsa sign-req client "$CLIENT_NAME"

# Create client config directory
mkdir -p /etc/openvpn/clients/$CLIENT_NAME

# Copy client files
cp pki/ca.crt /etc/openvpn/clients/$CLIENT_NAME/
cp pki/issued/$CLIENT_NAME.crt /etc/openvpn/clients/$CLIENT_NAME/
cp pki/private/$CLIENT_NAME.key /etc/openvpn/clients/$CLIENT_NAME/
cp /etc/openvpn/ta.key /etc/openvpn/clients/$CLIENT_NAME/

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Generate client config
cat > /etc/openvpn/clients/$CLIENT_NAME/$CLIENT_NAME.ovpn << EOF
client
dev tun
proto ${vpn_protocol}
remote $PUBLIC_IP ${vpn_port}
resolv-retry infinite
nobind
user nobody
group nogroup
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-GCM
auth SHA256
verb 3
key-direction 1

<ca>
$(cat /etc/openvpn/clients/$CLIENT_NAME/ca.crt)
</ca>

<cert>
$(cat /etc/openvpn/clients/$CLIENT_NAME/$CLIENT_NAME.crt)
</cert>

<key>
$(cat /etc/openvpn/clients/$CLIENT_NAME/$CLIENT_NAME.key)
</key>

<tls-auth>
$(cat /etc/openvpn/clients/$CLIENT_NAME/ta.key)
</tls-auth>
EOF

echo "Client configuration generated: /etc/openvpn/clients/$CLIENT_NAME/$CLIENT_NAME.ovpn"
EOSCRIPT

chmod +x /root/generate-client.sh

# Start and enable OpenVPN
systemctl enable openvpn@server
systemctl start openvpn@server

# Create initial client configs for testers
for i in {1..3}; do
    /root/generate-client.sh "tester$i"
done

echo "VPN Gateway setup complete!"