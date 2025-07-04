data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
      "Delete",
      "List",
      "Purge",
      "Recover",
      "Set",
    ]
  }
}

resource "azurerm_key_vault_secret" "all" {
  for_each         = var.secrets
  key_vault_id     = azurerm_key_vault.this.id
  name             = each.value.name
  value_wo         = each.value.value_wo
  value_wo_version = each.value.value_wo_version
}

ephemeral "azurerm_key_vault_secret" "all" {
  for_each     = var.secrets
  name         = each.value.name
  key_vault_id = azurerm_key_vault.this.id
}
