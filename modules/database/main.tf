module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = concat(local.naming_suffix, var.extra_naming_suffix)
}

resource "azurerm_mysql_flexible_server" "this" {
  name                         = module.naming.mysql_flexible_server.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  administrator_login          = var.admin_username
  administrator_password       = var.admin_password
  sku_name                     = var.sku
  version                      = var.db_version
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  backup_retention_days        = var.backup_retention_days
  private_dns_zone_id          = var.private_dns_zone_id
  delegated_subnet_id          = var.snet_id

  storage {
    size_gb            = var.storage_size_gb
    auto_grow_enabled  = var.storage_auto_grow_enabled
    iops               = var.storage_iops
    io_scaling_enabled = var.storage_io_scaling_enabled
  }
}

resource "azurerm_mysql_flexible_database" "this" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  charset             = var.charset
  collation           = var.collation
}
