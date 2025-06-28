output "dc_instance_id" {
  description = "ID of the domain controller instance"
  value       = aws_instance.domain_controller.id
}

output "dc_private_ip" {
  description = "Private IP of the domain controller"
  value       = aws_instance.domain_controller.private_ip
}

output "member_server_ids" {
  description = "IDs of member server instances"
  value       = aws_instance.member_servers[*].id
}

output "member_server_ips" {
  description = "Private IPs of member servers"
  value       = aws_instance.member_servers[*].private_ip
}

output "domain_info" {
  description = "Domain information"
  value = {
    domain_name    = var.domain_name
    domain_netbios = var.domain_netbios
    dc_ip          = aws_instance.domain_controller.private_ip
  }
}

output "test_users" {
  description = "Test user accounts created"
  value = [
    "jsmith (IT Admin)",
    "jdoe (Finance)",
    "bjohnson (Developer)", 
    "awilliams (IT Admin)"
  ]
}