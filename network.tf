
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
  address_prefixes     = var.mgmt_address_space
}

resource "azurerm_subnet" "ftdv-diagnostic" {
  name                 = "diagnostic-${local.name_tag}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = var.diagnostic_address_space
}

resource "azurerm_subnet" "ftdv-outside" {
  name                 = "outside-${local.name_tag}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = var.outside_address_space
}

resource "azurerm_subnet" "ftdv-inside" {
  name                 = "inside-${local.name_tag}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = var.inside_address_space
}
