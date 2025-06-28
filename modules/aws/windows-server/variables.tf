variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "server_number" {
  description = "Server number for naming"
  type        = string
  default     = "01"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for Windows Server (optional, will use latest if not specified)"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID where server will be deployed"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 50
}

variable "admin_password" {
  description = "Administrator password"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}