output "secrets" {
  description = "Retrieved Secrets"
  value       = ephemeral.azurerm_key_vault_secret.all
  sensitive   = true
  ephemeral   = true
}