################################################################################################################################
# FTD config
################################################################################################################################


# FTD routing:

resource "azurerm_subnet" "ftdv-management" {
  name                 = "management-${local.name_tag}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = [var.ftd_address_space[1]]
}

resource "azurerm_subnet" "ftdv-diagnostic" {
  name                 = "diagnostic-${local.name_tag}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = [var.ftd_address_space[2]]
}

resource "azurerm_subnet" "ftdv-outside" {
  name                 = "outside-${local.name_tag}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = [var.ftd_address_space[3]]
}

resource "azurerm_subnet" "ftdv-inside" {
  name                 = "inside-${local.name_tag}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = [var.ftd_address_space[4]]
}

resource "azurerm_route_table" "FTD_NIC0" {
  name                = "${var.prefix}-RT-Subnet0-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name

}

resource "azurerm_route" "internet_route_NIC0" {
  name                   = "default-route-${local.name_tag}"
  resource_group_name    = azurerm_resource_group.app_rg.name
  route_table_name       = azurerm_route_table.FTD_NIC0.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "Internet"
}

resource "azurerm_route_table" "FTD_NIC1" {
  name                = "${var.prefix}-RT-Subnet1-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name

}
resource "azurerm_route_table" "FTD_NIC2" {
  name                = "${var.prefix}-RT-Subnet2-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name
}

resource "azurerm_route" "internet_route_NIC2" {
  name                   = "default-route-${local.name_tag}"
  resource_group_name    = azurerm_resource_group.app_rg.name
  route_table_name       = azurerm_route_table.FTD_NIC2.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "Internet"
}

resource "azurerm_route_table" "FTD_NIC3" {
  name                = "${var.prefix}-RT-Subnet3-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name
}

resource "azurerm_subnet_route_table_association" "example1" {
  subnet_id                 = azurerm_subnet.ftdv-management.id
  route_table_id            = azurerm_route_table.FTD_NIC0.id
}
resource "azurerm_subnet_route_table_association" "example2" {
  subnet_id                 = azurerm_subnet.ftdv-diagnostic.id
  route_table_id            = azurerm_route_table.FTD_NIC1.id
}
resource "azurerm_subnet_route_table_association" "example3" {
  subnet_id                 = azurerm_subnet.ftdv-outside.id
  route_table_id            = azurerm_route_table.FTD_NIC2.id
}
resource "azurerm_subnet_route_table_association" "example4" {
  subnet_id                 = azurerm_subnet.ftdv-inside.id
  route_table_id            = azurerm_route_table.FTD_NIC3.id
}

################################################################################################################################
# Network Interface Creation, Public IP Creation and Network Security Group Association
################################################################################################################################

resource "azurerm_network_interface" "ftdv-interface-management" {
  name                      = "${var.prefix}-Nic0"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.app_rg.name

  ip_configuration {
    name                          = "Nic0"
    subnet_id                     = azurerm_subnet.ftdv-management.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ftdv-mgmt-interface.id
  }
}
resource "azurerm_network_interface" "ftdv-interface-diagnostic" {
  name                      = "${var.prefix}-Nic1"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.app_rg.name
  depends_on                = [azurerm_network_interface.ftdv-interface-management]
  ip_configuration {
    name                          = "Nic1"
    subnet_id                     = azurerm_subnet.ftdv-diagnostic.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "ftdv-interface-outside" {
  name                      = "${var.prefix}-Nic2"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.app_rg.name
  depends_on                = [azurerm_network_interface.ftdv-interface-diagnostic]
  ip_configuration {
    name                          = "Nic2"
    subnet_id                     = azurerm_subnet.ftdv-outside.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ftdv-outside-interface.id
  }
}
resource "azurerm_network_interface" "ftdv-interface-inside" {
  name                      = "${var.prefix}-Nic3"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.app_rg.name
  depends_on                = [azurerm_network_interface.ftdv-interface-outside]
  ip_configuration {
    name                          = "Nic3"
    subnet_id                     = azurerm_subnet.ftdv-inside.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "ftdv-mgmt-interface" {
  name                         = "management-public-ip"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.app_rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic" 
}
resource "azurerm_public_ip" "ftdv-outside-interface" {
  name                         = "outside-public-ip"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.app_rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic" 
}

resource "azurerm_network_interface_security_group_association" "FTDv_NIC0_NSG" {
  network_interface_id      = azurerm_network_interface.ftdv-interface-management.id
  network_security_group_id = azurerm_network_security_group.allow_web.id
}
resource "azurerm_network_interface_security_group_association" "FTDv_NIC1_NSG" {
  network_interface_id      = azurerm_network_interface.ftdv-interface-diagnostic.id
  network_security_group_id = azurerm_network_security_group.allow_web.id
}
resource "azurerm_network_interface_security_group_association" "FTDv_NIC2_NSG" {
  network_interface_id      = azurerm_network_interface.ftdv-interface-outside.id
  network_security_group_id = azurerm_network_security_group.allow_web.id
}
resource "azurerm_network_interface_security_group_association" "FTDv_NIC3_NSG" {
  network_interface_id      = azurerm_network_interface.ftdv-interface-inside.id
  network_security_group_id = azurerm_network_security_group.allow_web.id
}
################################################################################################################################
# FTDv Instance Creation
################################################################################################################################

resource "azurerm_virtual_machine" "ftdv-instance" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.app_rg.name
  
  depends_on = [
    azurerm_network_interface.ftdv-interface-management,
    azurerm_network_interface.ftdv-interface-diagnostic,
    azurerm_network_interface.ftdv-interface-outside,
    azurerm_network_interface.ftdv-interface-inside
  ]
  
  primary_network_interface_id = azurerm_network_interface.ftdv-interface-management.id
  network_interface_ids = [azurerm_network_interface.ftdv-interface-management.id,
                                                        azurerm_network_interface.ftdv-interface-diagnostic.id,
                                                        azurerm_network_interface.ftdv-interface-outside.id,
                                                        azurerm_network_interface.ftdv-interface-inside.id]
  vm_size               = var.VMSize


  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  plan {
    name = var.ftd1_config.plan.name
    publisher = var.ftd1_config.plan.publisher
    product = var.ftd1_config.plan.product
  }

  storage_image_reference {
    publisher = var.ftd1_config.storage_image_reference.publisher
    offer     = var.ftd1_config.storage_image_reference.offer
    sku       = var.ftd1_config.storage_image_reference.sku
    version   =var.ftd1_config.storage_image_reference.version
  }
  storage_os_disk {
    name              = var.ftd1_config.storage_os_disk.name
    caching           = var.ftd1_config.storage_os_disk.caching
    create_option     = var.ftd1_config.storage_os_disk.create_option
    managed_disk_type = var.ftd1_config.storage_os_disk.managed_disk_type
  }
  os_profile {
    admin_username = var.ftd1_config.os_profile.admin_username
    admin_password = var.ftd1_config.os_profile.admin_password
    computer_name  = var.ftd1_config.os_profile.computer_name
    custom_data = data.template_file.startup_file.rendered

  }
  os_profile_linux_config {
    disable_password_authentication = false

  }

}

################################################################################################################################
# Cisco ISE Instance Creation
################################################################################################################################
#
#resource "azurerm_network_interface" "ise-interface-management" {
#  name                      = "cisco-ise-Nic0"
#  location                  = var.location
#  resource_group_name       = azurerm_resource_group.app_rg.name
#
#  ip_configuration {
#    name                          = "ise-Nic0"
#    subnet_id                     = azurerm_subnet.ftdv-management.id
#    private_ip_address_allocation = "Dynamic"
#    public_ip_address_id          = azurerm_public_ip.ise-mgmt-interface.id
#  }
#}
#
#resource "azurerm_public_ip" "ise-mgmt-interface" {
#  name                         = "ise-management-public-ip"
#  location                     = var.location
#  resource_group_name          = azurerm_resource_group.app_rg.name
#  allocation_method   = "Dynamic"
#  sku                 = "Basic" 
#}
#
#resource "azurerm_network_interface_security_group_association" "ISE_NIC0_NSG" {
#  network_interface_id      = azurerm_network_interface.ise-interface-management.id
#  network_security_group_id = azurerm_network_security_group.allow_web.id
#}
#
#
#resource "azurerm_virtual_machine" "Cisco_ISE" {
#  name                  = "${var.prefix}-vm-Cisco-ISE"
#  location              = var.location
#  resource_group_name   = azurerm_resource_group.app_rg.name
#  
#  depends_on = [
#    azurerm_network_interface.ise-interface-management,
#  ]
#  
#  primary_network_interface_id = azurerm_network_interface.ise-interface-management.id
#  network_interface_ids = [azurerm_network_interface.ise-interface-management.id]
#  vm_size               = "Standard_D8s_v4"
#
#
#  delete_os_disk_on_termination = true
#  delete_data_disks_on_termination = true
#
#  plan {
#    name      = "cisco-ise_3_4"        # Wskaż nazwę obrazu Cisco ISE, jeśli jest dostępny w Azure Marketplace
#    publisher = "cisco"                  # Wydawca obrazu
#    product   = "cisco-ise-virtual"              # Produkt Cisco ISE
#  }
#
#  storage_image_reference {
#    # Obraz Cisco ISE w wersji 3.4
#    publisher = "cisco"
#    offer     = "cisco-ise-virtual"
#    sku       = "cisco-ise_3_4"  # Wersja obrazu
#    version   = "3.4.608"  # Konkretna wersja obrazu
#  }
#
#  storage_os_disk {
#    name              = "ise-os-disk"
#    caching           = "ReadWrite"
#    create_option     = "FromImage"
#    managed_disk_type = "Standard_LRS"
#  }
#
#  os_profile {
#    admin_username = var.username
#    admin_password = var.password
#    computer_name  = "ise-vmka"
#    #custom_data = data.template_file.startup_file.rendered
#  }
#  os_profile_linux_config {
#    disable_password_authentication = false
#
#  }
#
#}