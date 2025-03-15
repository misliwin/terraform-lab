##################################################################################
# OUTPUTS
##################################################################################

output "nginx_public_ip" {
  value = azurerm_public_ip.nginx_public_ip[0].ip_address
}

output "nginx_public_ip2" {
  value = azurerm_public_ip.nginx_public_ip[1].ip_address
}


output "public_ip_address" {
  value = azurerm_public_ip.ftdv-mgmt-interface.ip_address
}

output "lb-public-ip" {
  value = azurerm_public_ip.lb-public-ip.ip_address
}
