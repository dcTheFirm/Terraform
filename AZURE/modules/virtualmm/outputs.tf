    output "vm_public_ip" {
  value = azurerm_public_ip.app_pip.ip_address
}

output "ssh_command" {
  value = "ssh azureuser@${azurerm_public_ip.app_pip.ip_address}"
}