##############################
## Deploy Windows VM - Main ##
##############################

# Create Network Security Group to Access VM from Internet
resource "azurerm_network_security_group" "windows-nsg" {
  name                = "${var.company}-${var.environment}-windows-nsg"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name

  security_rule {
    name                       = "AllowRDP"
    description                = "Allow RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*" 
  }
  security_rule {
    name                       = "AllowHTTP"
    description                = "Allow HTTP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*" 
  }
  security_rule {
    name                       = "AllowHTTPS"
    description                = "Allow HTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*" 
  }

  tags = {
    application = var.app_name
    environment = var.environment 
  }
}

###########################
#  Windows VM 1 Creation  #
###########################

# Associate the NSG with the Subnet1
resource "azurerm_subnet_network_security_group_association" "windows1-nsg-association" {
  subnet_id                 = azurerm_subnet.network-subnet1.id
  network_security_group_id = azurerm_network_security_group.windows-nsg.id
}

# Get a Static Public IP for Windows VM1
resource "azurerm_public_ip" "windows-ip1" {
  name                = "${var.company}-${var.environment}-windows-ip1"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name
  allocation_method   = "Static"
  
  tags = { 
    application = var.app_name
    environment = var.environment 
  }
}

# Create Network Card for Windows VM1
resource "azurerm_network_interface" "windows-nic1" {
  name                      = "${var.company}-${var.environment}-windows-nic1"
  location                  = azurerm_resource_group.network-rg.location
  resource_group_name       = azurerm_resource_group.network-rg.name
  network_security_group_id = azurerm_network_security_group.windows-nsg.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.network-subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows-ip1.id
  }

  tags = { 
    application = var.app_name
    environment = var.environment 
  }
}

# Create Windows Server 1
resource "azurerm_virtual_machine" "windows-vm1" {
  name                  = "${var.company}-${var.environment}-windows-vm1"
  location              = azurerm_resource_group.network-rg.location
  resource_group_name   = azurerm_resource_group.network-rg.name
  network_interface_ids = [azurerm_network_interface.windows-nic1.id]
  vm_size               = var.windows-vm1-size

  # Comment this line to keep the OS disk when deleting the VM
  delete_os_disk_on_termination = true
  # Comment this line to keep the data disks when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"    
    sku       = var.windows-2019-sku
    version   = "latest"
  }
  
  storage_os_disk {
    name              = "${var.company}-${var.environment}-windows-vm1-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.windows-vm1-hostname
    admin_username = var.windows-vm1-admin-username
    admin_password = azurerm_key_vault_secret.adminpassword.id
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }

  tags = {
    application = var.app_name
    environment = var.environment 
  }
}


###########################
#  Windows VM 2 Creation  #
###########################

# Associate the NSG with the Subnet2
resource "azurerm_subnet_network_security_group_association" "windows-vm2-nsg-association" {
  subnet_id                 = azurerm_subnet.network-subnet2.id
  network_security_group_id = azurerm_network_security_group.windows-nsg.id
}

# Get a Static Public IP for Windows VM2
resource "azurerm_public_ip" "windows-ip2" {
  name                = "${var.company}-${var.environment}-windows-ip2"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name
  allocation_method   = "Static"
  
  tags = { 
    application = var.app_name
    environment = var.environment 
  }
}

# Create Network Card for Windows VM2
resource "azurerm_network_interface" "windows-nic2" {
  name                      = "${var.company}-${var.environment}-windows-nic2"
  location                  = azurerm_resource_group.network-rg.location
  resource_group_name       = azurerm_resource_group.network-rg.name
  network_security_group_id = azurerm_network_security_group.windows-nsg.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.network-subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows-ip2.id
  }

  tags = { 
    application = var.app_name
    environment = var.environment 
  }
}

# Create Windows Server 2
resource "azurerm_virtual_machine" "windows-vm2" {
  name                  = "${var.company}-${var.environment}-windows-vm2"
  location              = azurerm_resource_group.network-rg.location
  resource_group_name   = azurerm_resource_group.network-rg.name
  network_interface_ids = [azurerm_network_interface.windows-nic2.id]
  vm_size               = var.windows-vm2-size

  # Comment this line to keep the OS disk when deleting the VM
  delete_os_disk_on_termination = true
  # Comment this line to keep the data disks when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"    
    sku       = var.windows-2019-sku
    version   = "latest"
  }
  
  storage_os_disk {
    name              = "${var.company}-${var.environment}-windows-vm2-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.windows-vm2-hostname
    admin_username = var.windows-vm2-admin-username
    admin_password = azurerm_key_vault_secret.adminpassword.id
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }

  tags = {
    application = var.app_name
    environment = var.environment 
  }
}