data "azurerm_key_vault" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "all" {
  for_each     = var.secrets
  name         = each.value
  key_vault_id = data.azurerm_key_vault.this.id
}
