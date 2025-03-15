# Azure LB


resource "azurerm_public_ip" "lb-public-ip" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"  # Zmieniono na Standard
}




resource "azurerm_lb" "front_external_lb" {
  name                = "external_lb-${local.name_tag}"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name

  frontend_ip_configuration {
    name                 = "frontend_ip_IPAddress"
    public_ip_address_id = azurerm_public_ip.lb-public-ip.id
    private_ip_address_allocation = "Dynamic"  
  }
  
}


resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
  loadbalancer_id = azurerm_lb.front_external_lb.id
  name            = "lb-BackEndAddressPool-${local.name_tag}"
}

resource "azurerm_lb_backend_address_pool_address" "lb_backend_pool_address_nginx1" {
  count = var.instances_count
  name                    = "lb_backend_pool_nginx-${local.name_tag}-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_pool.id
  virtual_network_id      = azurerm_virtual_network.app_vnet.id
  ip_address              = azurerm_network_interface.nginx_nic[count.index].ip_configuration[0].private_ip_address
}

/*
resource "azurerm_lb_backend_address_pool_address" "lb_backend_pool_address_nginx2" {
  name                    = "lb_backend_pool_nginx2-${local.name_tag}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_pool.id
  virtual_network_id      = azurerm_virtual_network.app_vnet.id
  ip_address              = azurerm_network_interface.nginx_nic2.ip_configuration[0].private_ip_address
}
*/



resource "azurerm_lb_probe" "lb_probe-webapp" {
  name                           = "lb-probe-${local.name_tag}"
  loadbalancer_id                = azurerm_lb.front_external_lb.id
  protocol                       = "Http"
  port                           = 80
  request_path                   = "/"
  interval_in_seconds            = 15
}

resource "azurerm_lb_rule" "lb_rule-webapp" {
  name                           = "my-lb-rule-${local.name_tag}"
  #resource_group_name            = azurerm_resource_group.app_rg.name
  loadbalancer_id                = azurerm_lb.front_external_lb.id
  frontend_ip_configuration_name = azurerm_lb.front_external_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
  probe_id                       = azurerm_lb_probe.lb_probe-webapp.id

  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
}


#Azure LB target group

#azure LB listener

# azure lb target group attachment

