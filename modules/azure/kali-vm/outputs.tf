output "vm_id" {
  description = "ID of the Kali VM"
  value       = azurerm_linux_virtual_machine.kali.id
}

output "private_ip" {
  description = "Private IP of the Kali VM"
  value       = azurerm_network_interface.kali.private_ip_address
}

output "network_interface_id" {
  description = "Network interface ID"
  value       = azurerm_network_interface.kali.id
}