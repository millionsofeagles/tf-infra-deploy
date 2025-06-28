output "instance_id" {
  description = "ID of the Kali instance"
  value       = aws_instance.kali.id
}

output "public_ip" {
  description = "Public IP of the Kali instance"
  value       = aws_instance.kali.public_ip
}

output "private_ip" {
  description = "Private IP of the Kali instance"
  value       = aws_instance.kali.private_ip
}

output "public_dns" {
  description = "Public DNS of the Kali instance"
  value       = aws_instance.kali.public_dns
}