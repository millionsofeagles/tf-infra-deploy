resource "azurerm_network_interface" "kali" {
  name                = "${var.name_prefix}-kali-nic-${var.instance_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "kali" {
  name                = "${var.name_prefix}-kali-vm-${var.instance_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  network_interface_ids = [
    azurerm_network_interface.kali.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.os_disk_size
  }

  source_image_reference {
    publisher = "kali-linux"
    offer     = "kali"
    sku       = var.kali_sku
    version   = "latest"
  }

  custom_data = var.custom_data != "" ? base64encode(var.custom_data) : null

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-kali-vm-${var.instance_suffix}"
      Type = "Pentesting-Kali"
    }
  )
}