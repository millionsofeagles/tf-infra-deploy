locals {
  name_prefix = "${var.project_name}-${var.environment}-aws"
  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      Cloud       = "AWS"
    }
  )
}

resource "aws_vpc" "pentest" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

resource "aws_internet_gateway" "pentest" {
  vpc_id = aws_vpc.pentest.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.pentest.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-subnet"
      Type = "Public"
    }
  )
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.pentest.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-subnet"
      Type = "Private"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.pentest.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pentest.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-rt"
    }
  )
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "kali" {
  name_prefix = "${local.name_prefix}-kali-"
  description = "Security group for Kali Linux pentesting instances"
  vpc_id      = aws_vpc.pentest.id

  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_ips
  }

  ingress {
    description = "VNC from allowed IPs"
    from_port   = 5900
    to_port     = 5910
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_ips
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-kali-sg"
    }
  )
}

resource "aws_security_group" "target" {
  name_prefix = "${local.name_prefix}-target-"
  description = "Security group for target instances"
  vpc_id      = aws_vpc.pentest.id

  ingress {
    description     = "All traffic from Kali SG"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.kali.id]
  }

  ingress {
    description = "RDP from allowed IPs"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.allowed_rdp_ips
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-target-sg"
    }
  )
}

resource "aws_key_pair" "pentest" {
  key_name   = "${local.name_prefix}-key"
  public_key = var.ssh_public_key

  tags = local.common_tags
}

module "kali_instances" {
  source = "../../modules/aws/kali-instance"
  count  = var.tester_count

  name_prefix        = local.name_prefix
  instance_suffix    = format("%02d", count.index + 1)
  instance_type      = var.kali_instance_type
  subnet_id          = aws_subnet.public.id
  security_group_ids = [aws_security_group.kali.id]
  key_name           = aws_key_pair.pentest.key_name
  root_volume_size   = 50
  tags               = local.common_tags

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y git tmux
    
    # Install additional pentesting tools if needed
    # apt-get install -y tool1 tool2
    
    # Configure VNC server if needed
    # apt-get install -y tightvncserver
  EOF
}

resource "aws_security_group" "vpn" {
  count = var.enable_vpn_gateway ? 1 : 0
  
  name_prefix = "${local.name_prefix}-vpn-"
  description = "Security group for VPN gateway"
  vpc_id      = aws_vpc.pentest.id

  ingress {
    description = "OpenVPN"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_ips
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpn-sg"
    }
  )
}

module "vpn_gateway" {
  count  = var.enable_vpn_gateway ? 1 : 0
  source = "../../modules/aws/vpn-gateway"

  name_prefix        = local.name_prefix
  subnet_id          = aws_subnet.public.id
  security_group_ids = [aws_security_group.vpn[0].id]
  key_name           = aws_key_pair.pentest.key_name
  tags               = local.common_tags
}

resource "aws_security_group" "windows" {
  count = var.enable_windows_server ? 1 : 0
  
  name_prefix = "${local.name_prefix}-windows-"
  description = "Security group for Windows servers"
  vpc_id      = aws_vpc.pentest.id

  # Allow traffic from Kali security group
  ingress {
    description     = "All traffic from Kali instances"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.kali.id]
  }

  # RDP from allowed IPs
  ingress {
    description = "RDP from allowed IPs"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.allowed_rdp_ips
  }

  # Common Windows ports for testing
  ingress {
    description = "SMB"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "WinRM HTTP"
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "WinRM HTTPS"
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-windows-sg"
    }
  )
}

module "windows_servers" {
  count  = var.enable_windows_server ? var.windows_server_count : 0
  source = "../../modules/aws/windows-server"

  name_prefix        = local.name_prefix
  server_number      = format("%02d", count.index + 1)
  subnet_id          = aws_subnet.private.id
  security_group_ids = [aws_security_group.windows[0].id]
  key_name           = aws_key_pair.pentest.key_name
  admin_password     = var.windows_admin_password
  tags               = local.common_tags
}

data "aws_availability_zones" "available" {
  state = "available"
}