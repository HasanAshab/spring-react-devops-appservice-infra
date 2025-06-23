output "url" {
  value = "http://${azurerm_public_ip.appgw.ip_address}:${var.port}"
}

output "backend_address_pool_ids" {
  value = azurerm_application_gateway.main.backend_address_pool.*.id
}