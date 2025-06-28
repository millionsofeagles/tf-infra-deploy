locals {
  common_ports = {
    ssh = {
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      description = "SSH access"
    }
    rdp = {
      protocol    = "tcp"
      from_port   = 3389
      to_port     = 3389
      description = "RDP access"
    }
    http = {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      description = "HTTP access"
    }
    https = {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      description = "HTTPS access"
    }
    vnc = {
      protocol    = "tcp"
      from_port   = 5900
      to_port     = 5910
      description = "VNC access"
    }
  }
}