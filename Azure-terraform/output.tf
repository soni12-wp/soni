output "resource_group_name" {
  value = azurerm_resource_group.azure-resource.name
}

output "public_ip_address" {
  value = azurerm_windows_virtual_machine.main-azure.public_ip_addresses
}

output "admin_password" {
  sensitive = true
  value     = azurerm_windows_virtual_machine.main-azure.admin_password
}

output "public_ip_addressl" {
  value = azurerm_linux_virtual_machine.my_terraform_vm.public_ip_address
}