locals {
  name_prefix = "${var.project_name}-${var.environment}-azure"
  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      Cloud       = "Azure"
    }
  )
}

resource "azurerm_resource_group" "pentest" {
  name     = "${local.name_prefix}-rg"
  location = var.azure_location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "pentest" {
  name                = "${local.name_prefix}-vnet"
  address_space       = [var.vpc_cidr]
  location            = azurerm_resource_group.pentest.location
  resource_group_name = azurerm_resource_group.pentest.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "public" {
  name                 = "${local.name_prefix}-public-subnet"
  resource_group_name  = azurerm_resource_group.pentest.name
  virtual_network_name = azurerm_virtual_network.pentest.name
  address_prefixes     = [var.public_subnet_cidr]
}

resource "azurerm_subnet" "private" {
  name                 = "${local.name_prefix}-private-subnet"
  resource_group_name  = azurerm_resource_group.pentest.name
  virtual_network_name = azurerm_virtual_network.pentest.name
  address_prefixes     = [var.private_subnet_cidr]
}

resource "azurerm_network_security_group" "kali" {
  name                = "${local.name_prefix}-kali-nsg"
  location            = azurerm_resource_group.pentest.location
  resource_group_name = azurerm_resource_group.pentest.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_ssh_ips
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "VNC"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5900-5910"
    source_address_prefixes    = var.allowed_ssh_ips
    destination_address_prefix = "*"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-kali-nsg"
    }
  )
}

resource "azurerm_network_security_group" "target" {
  name                = "${local.name_prefix}-target-nsg"
  location            = azurerm_resource_group.pentest.location
  resource_group_name = azurerm_resource_group.pentest.name

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.allowed_rdp_ips
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowFromKali"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_subnet.public.address_prefixes[0]
    destination_address_prefix = "*"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-target-nsg"
    }
  )
}

resource "azurerm_subnet_network_security_group_association" "kali" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.kali.id
}

resource "azurerm_subnet_network_security_group_association" "target" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.target.id
}

resource "azurerm_public_ip" "kali" {
  name                = "${local.name_prefix}-kali-pip"
  location            = azurerm_resource_group.pentest.location
  resource_group_name = azurerm_resource_group.pentest.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-kali-pip"
    }
  )
}

module "kali_vm" {
  source = "../../modules/azure/kali-vm"

  name_prefix         = local.name_prefix
  instance_suffix     = "01"
  location            = azurerm_resource_group.pentest.location
  resource_group_name = azurerm_resource_group.pentest.name
  vm_size             = var.kali_vm_size
  subnet_id           = azurerm_subnet.public.id
  public_ip_id        = azurerm_public_ip.kali.id
  ssh_public_key      = var.ssh_public_key
  os_disk_size        = 50
  tags                = local.common_tags

  custom_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y git tmux
    
    # Install additional pentesting tools if needed
    # apt-get install -y tool1 tool2
    
    # Configure VNC server if needed
    # apt-get install -y tightvncserver
  EOF
}