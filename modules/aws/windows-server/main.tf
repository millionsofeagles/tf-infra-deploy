resource "aws_instance" "windows_server" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.windows.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user_data.ps1", {
    admin_password = var.admin_password
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-windows-${var.server_number}"
      Type = "Windows-Server"
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