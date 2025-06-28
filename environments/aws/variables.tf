variable "project_name" {
  description = "Name of the pentesting project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
}

variable "allowed_ssh_ips" {
  description = "List of IPs allowed to SSH"
  type        = list(string)
}

variable "allowed_rdp_ips" {
  description = "List of IPs allowed to RDP"
  type        = list(string)
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

variable "kali_instance_type" {
  description = "Instance type for Kali Linux"
  type        = string
  default     = "t3.medium"
}

variable "tester_count" {
  description = "Number of Kali instances for testers"
  type        = number
  default     = 1
}

variable "enable_vpn_gateway" {
  description = "Deploy VPN gateway for remote access"
  type        = bool
  default     = false
}

variable "enable_windows_server" {
  description = "Deploy Windows server for compatibility testing"
  type        = bool
  default     = false
}

variable "windows_admin_password" {
  description = "Administrator password for Windows server"
  type        = string
  sensitive   = true
  default     = ""
}

variable "windows_server_count" {
  description = "Number of Windows servers to deploy"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}