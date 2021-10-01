########################################
## Deploy Windows Bastion VM - Output ##
########################################

# Windows VM1 ID
output "windows_vm1_id" {
  value = azurerm_virtual_machine.windows-vm1.id
}

# Windows VM1 Username
output "windows_vm1_username" {
  value = windows-vm1-admin-username
}

# Windows VM1 Password
output "windows_vm1_password" {
  value = var.windows-vm1-admin-password
}

# Windows VM1 Public IP
output "windows_vm1_public_ip" {
  value = azurerm_public_ip.windows-ip1.ip_address
}

# Windows VM2 ID
output "windows_vm_id" {
  value = azurerm_virtual_machine.windows-vm2.id
}

# Windows VM2 Username
output "windows_vm2_username" {
  value = windows-vm1-admin-username
}

# Windows VM2 Password
output "bastion_windows_vm2_password" {
  value = var.windows-vm2-admin-password
}

# Windows VM2 Public IP
output "windows_public_ip" {
  value = azurerm_public_ip.windows-ip2.ip_address
}