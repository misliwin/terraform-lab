
# INTERNET ACCESS for VM web server# - NSG


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


########## Internal NSG ###############

resource "azurerm_network_security_group" "web_server" {
  name                = "lb-nsg-${local.name_tag}"
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
    source_address_prefix      = azurerm_subnet.dmz_subnets[0].address_prefixes[0]
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
    source_address_prefix      = azurerm_subnet.dmz_subnets[0].address_prefixes[0]
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

