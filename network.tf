
# vnet #

resource "azurerm_virtual_network" "app_vnet" {
  name                = "app-vnet-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name
  address_space       = var.vnet_address_space
}

# subnets both server and FTD #


resource "azurerm_subnet" "dmz_subnets" {
  count = var.vnet_subnet_count
  name                 = "dmz-subnet-${local.name_tag}-${count.index}"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  #address_prefixes     = [var.subnet_address_space[count.index]]
  address_prefixes     = [cidrsubnet(var.vnet_address_space[0], 8, count.index)]
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

resource "azurerm_subnet_route_table_association" "public_subnet_associations" {
  count = var.vnet_subnet_count
  subnet_id      = azurerm_subnet.dmz_subnets[count.index].id
  route_table_id = azurerm_route_table.app_route_table.id
}



############# Public IPs #################


######### Public IP for Web VM

resource "azurerm_public_ip" "nginx_public_ip" {
  count = var.instances_count
  name                = "nginx-public-ip-${local.name_tag}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic" 
}



######### Public IP for Web VM
/*
resource "azurerm_public_ip" "nginx_public_ip2" {
  name                = "nginx-public-ip2-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic" 
}
*/