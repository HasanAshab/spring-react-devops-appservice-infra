output "secrets" {
  description = "Retrieved Secrets"
  value = {
    for name, secret in data.azurerm_key_vault_secret.all :
    name => secret.value
  }
  sensitive = true
}