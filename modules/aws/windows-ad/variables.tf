variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "dc_number" {
  description = "Domain controller number"
  type        = string
  default     = "01"
}

variable "instance_type" {
  description = "EC2 instance type for DC"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for Windows Server (optional, will use latest if not specified)"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID where DC will be deployed"
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

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 50
}

variable "domain_name" {
  description = "Active Directory domain name (e.g., pentest.local)"
  type        = string
}

variable "domain_netbios" {
  description = "NetBIOS name for the domain"
  type        = string
  default     = "PENTEST"
}

variable "safe_mode_password" {
  description = "Safe mode administrator password"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Administrator password"
  type        = string
  sensitive   = true
}

variable "is_first_dc" {
  description = "Is this the first domain controller in the forest?"
  type        = bool
  default     = true
}

variable "member_server_count" {
  description = "Number of member servers to create"
  type        = number
  default     = 0
}

variable "member_server_instance_type" {
  description = "Instance type for member servers"
  type        = string
  default     = "t3.small"
}

variable "member_server_volume_size" {
  description = "Volume size for member servers in GB"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}