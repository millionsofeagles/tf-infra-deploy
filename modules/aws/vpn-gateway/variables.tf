variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for VPN gateway (optional, will use latest Ubuntu if not specified)"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID where VPN gateway will be deployed"
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
  default     = 20
}

variable "vpn_port" {
  description = "OpenVPN port"
  type        = number
  default     = 1194
}

variable "vpn_protocol" {
  description = "OpenVPN protocol (tcp/udp)"
  type        = string
  default     = "udp"
}

variable "vpn_network" {
  description = "VPN network CIDR"
  type        = string
  default     = "10.8.0.0"
}

variable "vpn_subnet_mask" {
  description = "VPN subnet mask"
  type        = string
  default     = "255.255.255.0"
}

variable "dns_servers" {
  description = "DNS servers to push to VPN clients"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}