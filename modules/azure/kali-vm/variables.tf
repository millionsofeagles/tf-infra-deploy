variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "instance_suffix" {
  description = "Suffix for instance name"
  type        = string
  default     = "01"
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "kali_sku" {
  description = "Kali Linux SKU"
  type        = string
  default     = "kali-2023-3"
}

variable "subnet_id" {
  description = "Subnet ID where VM will be deployed"
  type        = string
}

variable "public_ip_id" {
  description = "Public IP ID to associate with VM"
  type        = string
  default     = null
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "kaliuser"
}

variable "ssh_public_key" {
  description = "SSH public key for authentication"
  type        = string
}

variable "os_disk_size" {
  description = "Size of OS disk in GB"
  type        = number
  default     = 30
}

variable "custom_data" {
  description = "Custom data script (cloud-init)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}