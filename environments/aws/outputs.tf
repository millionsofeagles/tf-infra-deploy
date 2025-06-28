output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.pentest.id
}

output "kali_instances" {
  description = "Information about Kali instances"
  value = {
    for idx, instance in module.kali_instances : 
    "tester_${idx + 1}" => {
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
      ssh_command = "ssh -i <private_key_path> kali@${instance.public_ip}"
    }
  }
}

output "vpn_gateway" {
  description = "VPN gateway information"
  value = var.enable_vpn_gateway ? {
    public_ip    = module.vpn_gateway[0].public_ip
    ssh_command  = module.vpn_gateway[0].vpn_connection_info.ssh_command
    vpn_port     = module.vpn_gateway[0].vpn_connection_info.port
    vpn_protocol = module.vpn_gateway[0].vpn_connection_info.protocol
    client_config_help = "SSH to VPN gateway and run: cat /etc/openvpn/clients/<client-name>/<client-name>.ovpn"
  } : null
}

output "windows_servers" {
  description = "Windows servers information"
  value = var.enable_windows_server ? {
    for idx, server in module.windows_servers :
    "server_${idx + 1}" => {
      private_ip = server.private_ip
      rdp_command = "RDP to ${server.private_ip} as Administrator"
    }
  } : null
}

output "security_groups" {
  description = "Security group IDs"
  value = {
    kali    = aws_security_group.kali.id
    target  = aws_security_group.target.id
    vpn     = var.enable_vpn_gateway ? aws_security_group.vpn[0].id : null
    windows = var.enable_windows_server ? aws_security_group.windows[0].id : null
  }
}