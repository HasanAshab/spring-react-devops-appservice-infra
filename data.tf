data "azurerm_key_vault" "this" {
  name                = "kv-${local.project_name}-${terraform.workspace}"
  resource_group_name = "terraform"
}

data "azurerm_key_vault_secret" "database_admin_username" {
  name         = "database-admin-username"
  key_vault_id = data.azurerm_key_vault.this.id
}

data "azurerm_key_vault_secret" "database_admin_password" {
  name         = "database-admin-password"
  key_vault_id = data.azurerm_key_vault.this.id
}
