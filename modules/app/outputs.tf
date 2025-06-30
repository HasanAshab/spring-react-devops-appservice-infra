output "url" {
  value = "https://${azurerm_linux_web_app.this.default_hostname}"
}