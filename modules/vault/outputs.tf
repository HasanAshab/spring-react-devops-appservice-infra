output "resource_id" {
  description = "The Azure resource id of the key vault."
  value       = module.vault.resource_id
}

output "uri" {
  description = "The URI of the vault for performing operations on keys and secrets"
  value       = module.vault.uri
}
