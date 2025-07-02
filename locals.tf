locals {
  project_name = "three-tier-app"
  vnet_cidr    = "10.254.0.0/16"
  # db_dns_zone_name     = "privatelink.mysql.database.azure.com"
  database_admin_username = data.azurerm_key_vault_secret.database_admin_username.value
  database_admin_password = data.azurerm_key_vault_secret.database_admin_password.value
  extra_naming_suffix     = [local.project_name, terraform.workspace, var.location]
}
