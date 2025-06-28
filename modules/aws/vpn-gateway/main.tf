resource "aws_instance" "vpn_gateway" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  
  associate_public_ip_address = true
  source_dest_check          = false

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    vpn_port        = var.vpn_port
    vpn_protocol    = var.vpn_protocol
    vpn_network     = var.vpn_network
    vpn_subnet_mask = var.vpn_subnet_mask
    dns_servers     = join(" ", var.dns_servers)
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-vpn-gateway"
      Type = "VPN-Gateway"
    }
  )
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Ubuntu official AMI owner

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_eip" "vpn_gateway" {
  instance = aws_instance.vpn_gateway.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-vpn-gateway-eip"
    }
  )
}