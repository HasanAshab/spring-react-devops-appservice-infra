output "url" {
  value = "http://${azurerm_public_ip.appgw.ip_address}:${var.frontend_port}"
}

# output "backend_address_pool_id" {
#   value = azurerm_application_gateway.main.backend_address_pool[0].id
# }