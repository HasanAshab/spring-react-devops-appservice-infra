data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = var.sku
  soft_delete_retention_days    = var.soft_delete_retention_days
  enable_rbac_authorization     = true
  public_network_access_enabled = true
}

resource "azurerm_role_assignment" "secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "this" {
  for_each         = var.secrets
  key_vault_id     = azurerm_key_vault.this.id
  name             = each.value.name
  value_wo         = var.secrets_value[each.key]
  value_wo_version = each.value.version
}

ephemeral "azurerm_key_vault_secret" "all" {
  for_each     = azurerm_key_vault_secret.this
  name         = each.value.name
  key_vault_id = azurerm_key_vault.this.id
}
