
terraform {
  backend "azurerm" {
    resource_group_name   = "Terraform-storage-account-RG"
    storage_account_name  = "tfsamisliwin"
    container_name        = "terraform-state-misliwin"
    key                   = "terraform.tfstate"
    subscription_id       = "df5fd655-d63c-4ed8-8542-2ec6c39845f2"
    tenant_id             = "5ae1af62-9505-4097-a69a-c1553ef7840e"
    #access_key            = var.azure_storage_account_key
  }
}


##################################################################################
# PROVIDERS
##################################################################################

provider "azurerm" {
  features {}
  subscription_id = "df5fd655-d63c-4ed8-8542-2ec6c39845f2"
}



##################################################################################
# DATA
##################################################################################

data "template_file" "startup_file" {
  template = file(var.ftd_startup_file)
}

#data "azurerm_public_ip" "ftdv-mgmt-interface" {
#  name                = azurerm_public_ip.ftdv-mgmt-interface.name
#  resource_group_name = azurerm_virtual_machine.ftdv-instance.resource_group_name
#}


##################################################################################
# RESOURCES
##################################################################################

# RESOURCE GROUP #

resource "azurerm_resource_group" "app_rg" {
  name     = "MyRG-${local.name_tag}"
  location = var.location
}

# vnet #

resource "azurerm_virtual_network" "app_vnet" {
  name                = "app-vnet-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name
  address_space       = var.vnet_address_space
}

# subnets both server and FTD #


resource "azurerm_subnet" "dmz_subnet1" {
  name                 = "dmz-subnet-1-${local.name_tag}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = var.subnet_address_space
}


resource "azurerm_subnet" "ftdv-management" {
  name                 = "management-${local.name_tag}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "ftdv-diagnostic" {
  name                 = "diagnostic-${local.name_tag}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "ftdv-outside" {
  name                 = "outside-${local.name_tag}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "ftdv-inside" {
  name                 = "inside-${local.name_tag}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}

# INTERNET ACCESS for VM web server#

resource "azurerm_public_ip" "nginx_public_ip" {
  name                = "nginx-public-ip-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic" 
}

resource "azurerm_network_security_group" "allow_web" {
  name                = "nginx-nsg-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name

  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule { 
    name                       = "Allow_HTTPS"
    priority                   = 101  # Priorytet musi być inny niż w HTTP
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_All_Egress"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


# ROUTING #

resource "azurerm_route_table" "app_route_table" {
  name                = "app-route-table-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name
}

resource "azurerm_route" "internet_route" {
  name                   = "default-route-${local.name_tag}"
  resource_group_name    = azurerm_resource_group.app_rg.name
  route_table_name       = azurerm_route_table.app_route_table.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "Internet"
}

resource "azurerm_subnet_route_table_association" "public_subnet_association" {
  subnet_id      = azurerm_subnet.dmz_subnet1.id
  route_table_id = azurerm_route_table.app_route_table.id
}





# NETWORK INTERFACE #

resource "azurerm_network_interface" "nginx_nic" {
  name                = "nginx-nic-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name

  ip_configuration {
    name                          = "nginx-ip-config-${local.name_tag}"
    subnet_id                     = azurerm_subnet.dmz_subnet1.id
    public_ip_address_id          = azurerm_public_ip.nginx_public_ip.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "nginx_nic_nsg" {
  network_interface_id      = azurerm_network_interface.nginx_nic.id
  network_security_group_id = azurerm_network_security_group.allow_web.id
}

# VIRTUAL MACHINE #

resource "azurerm_linux_virtual_machine" "nginx_vm" {
  name                = "nginx-vm-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name
  size                = "Standard_B1s"
  admin_username      = local.username
  admin_password      = local.password

  network_interface_ids = [azurerm_network_interface.nginx_nic.id]

  #admin_ssh_key {
  #  username   = "mislwin"
  #  public_key = file(" /home/misliwin/.ssh/id_rsa.pub") # Zmień ścieżkę do klucza SSH
  #}
  disable_password_authentication = false  # Ustaw "false", aby umożliwić logowanie hasłem


  os_disk {
    caching              = var.vm_config.os_disk.caching
    storage_account_type = var.vm_config.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.vm_config.source_image_reference.publisher
    offer     = var.vm_config.source_image_reference.offer
    sku       = var.vm_config.source_image_reference.sku
    version   = var.vm_config.source_image_reference.version
  }

  

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    rm /var/www/html/index.nginx-debian.html
    echo '<html><head><title>Taco Team Server</title></head><body style="background-color:#1F778D"><p style="text-align: center;"><span style="color:#FFFFFF;"><span style="font-size:28px;">Strona stworzona przez terraform przez misliwin</span></span></p></body></html>' | tee /var/www/html/index.html
  EOF
  )
}





################################################################################################################################
# FTD config
################################################################################################################################


# FTD routing:


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
    name = "ftdv-azure-byol"
    publisher = "cisco"
    product = "cisco-ftdv"
  }

  storage_image_reference {
    publisher = "cisco"
    offer     = "cisco-ftdv"
    sku       = "ftdv-azure-byol"
    version   = var.Version
  }
  storage_os_disk {
    name              = "myosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    admin_username = var.username
    admin_password = var.password
    computer_name  = var.instancename
    custom_data = data.template_file.startup_file.rendered

  }
  os_profile_linux_config {
    disable_password_authentication = false

  }

}

################################################################################################################################
# Cisco ISE Instance Creation
################################################################################################################################

