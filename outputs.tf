##################################################################################
# OUTPUTS
##################################################################################

output "nginx_public_ip" {
  value = azurerm_public_ip.nginx_public_ip.ip_address
}

output "public_ip_address" {
  value = azurerm_public_ip.ftdv-mgmt-interface.ip_address
}