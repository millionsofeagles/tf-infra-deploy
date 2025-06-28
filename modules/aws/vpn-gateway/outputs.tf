output "instance_id" {
  description = "ID of the VPN gateway instance"
  value       = aws_instance.vpn_gateway.id
}

output "public_ip" {
  description = "Public IP of the VPN gateway"
  value       = aws_eip.vpn_gateway.public_ip
}

output "private_ip" {
  description = "Private IP of the VPN gateway"
  value       = aws_instance.vpn_gateway.private_ip
}

output "vpn_connection_info" {
  description = "VPN connection information"
  value = {
    server_ip   = aws_eip.vpn_gateway.public_ip
    port        = var.vpn_port
    protocol    = var.vpn_protocol
    ssh_command = "ssh -i <private_key> ubuntu@${aws_eip.vpn_gateway.public_ip}"
    client_config_location = "/etc/openvpn/clients/<client-name>/<client-name>.ovpn"
  }
}