resource "aws_instance" "kali" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.kali.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = var.user_data

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-kali-${var.instance_suffix}"
      Type = "Pentesting-Kali"
    }
  )
}

data "aws_ami" "kali" {
  most_recent = true
  owners      = ["679593333241"] # Kali Linux official AMI owner

  filter {
    name   = "name"
    values = ["kali-linux-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}