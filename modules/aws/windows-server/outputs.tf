output "instance_id" {
  description = "ID of the Windows server instance"
  value       = aws_instance.windows_server.id
}

output "private_ip" {
  description = "Private IP of the Windows server"
  value       = aws_instance.windows_server.private_ip
}

output "public_ip" {
  description = "Public IP of the Windows server (if assigned)"
  value       = aws_instance.windows_server.public_ip
}

output "rdp_info" {
  description = "RDP connection information"
  value = {
    ip_address = aws_instance.windows_server.private_ip
    username   = "Administrator"
    note       = "Use admin_password from terraform.tfvars"
  }
}