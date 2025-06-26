resource "azurerm_mysql_flexible_server" "main" {
  name                   = "mysql-${var.project_name}-${terraform.workspace}-${var.location}-001"
  location               = var.location
  resource_group_name    = var.resource_group_name
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  sku_name               = var.sku
  version                = var.db_version

  geo_redundant_backup_enabled = false
  # delegated_subnet_id    = 
  # public_network_access_enabled = false
  storage {
    size_gb = 20
  }
}

resource "azurerm_mysql_flexible_database" "main" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}
