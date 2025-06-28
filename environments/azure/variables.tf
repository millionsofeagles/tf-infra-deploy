variable "project_name" {
  description = "Name of the pentesting project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "azure_location" {
  description = "Azure region"
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VNet"
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
  description = "SSH public key for VM access"
  type        = string
}

variable "kali_vm_size" {
  description = "VM size for Kali Linux"
  type        = string
  default     = "Standard_B2s"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}