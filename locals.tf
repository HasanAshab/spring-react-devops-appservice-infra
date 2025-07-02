locals {
  project_name         = "three-tier-app"
  vnet_cidr            = "10.254.0.0/16"
  db_dns_zone_name     = "privatelink.mysql.database.azure.com"
  mysql_admin_username = data.azurerm_key_vault_secret.mysql_admin_username.value
  mysql_admin_password = data.azurerm_key_vault_secret.mysql_admin_password.value
}
