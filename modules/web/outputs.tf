output "url" {
  value = "http://${azurerm_linux_web_app.main.default_hostname}"
}