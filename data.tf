data "azurerm_key_vault" "this" {
  name                = "kv-${local.project_name}-${terraform.workspace}"
  resource_group_name = "terraform"
}

data "azurerm_key_vault_secret" "mysql_admin_username" {
  name         = "mysql-admin-username"
  key_vault_id = data.azurerm_key_vault.this.id
}

data "azurerm_key_vault_secret" "mysql_admin_password" {
  name         = "mysql-admin-password"
  key_vault_id = data.azurerm_key_vault.this.id
}
