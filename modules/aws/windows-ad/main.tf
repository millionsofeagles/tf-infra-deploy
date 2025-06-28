locals {
  dc_name = "${var.name_prefix}-dc-${var.dc_number}"
}

resource "aws_instance" "domain_controller" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.windows.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  
  iam_instance_profile = var.iam_instance_profile

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user_data.ps1", {
    domain_name        = var.domain_name
    domain_netbios     = var.domain_netbios
    safe_mode_password = var.safe_mode_password
    admin_password     = var.admin_password
    is_first_dc        = var.is_first_dc
  })

  tags = merge(
    var.tags,
    {
      Name = local.dc_name
      Type = "Domain-Controller"
      Domain = var.domain_name
    }
  )
}

resource "aws_instance" "member_servers" {
  count = var.member_server_count
  
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.windows.id
  instance_type          = var.member_server_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  root_block_device {
    volume_size = var.member_server_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/member_server_data.ps1", {
    domain_name    = var.domain_name
    admin_password = var.admin_password
    dc_ip          = aws_instance.domain_controller.private_ip
  })

  depends_on = [aws_instance.domain_controller]

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-member-${format("%02d", count.index + 1)}"
      Type = "Member-Server"
      Domain = var.domain_name
    }
  )
}

data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}