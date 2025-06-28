output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.pentest.name
}

output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.pentest.id
}

output "kali_vm_public_ip" {
  description = "Public IP of Kali VM"
  value       = azurerm_public_ip.kali.ip_address
}

output "kali_vm_private_ip" {
  description = "Private IP of Kali VM"
  value       = module.kali_vm.private_ip
}

output "kali_ssh_command" {
  description = "SSH command to connect to Kali VM"
  value       = "ssh -i <private_key_path> kaliuser@${azurerm_public_ip.kali.ip_address}"
}

output "nsg_kali_id" {
  description = "Kali NSG ID"
  value       = azurerm_network_security_group.kali.id
}

output "nsg_target_id" {
  description = "Target NSG ID"
  value       = azurerm_network_security_group.target.id
}