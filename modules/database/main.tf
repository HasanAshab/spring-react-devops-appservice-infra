module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming.git?ref=75d5afa" # v0.4.2
  suffix = concat(local.naming_suffix, var.extra_naming_suffix)
}

resource "azurerm_private_dns_zone" "this" {
  name                = local.dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = local.dns_zone_link_name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
  private_dns_zone_name = azurerm_private_dns_zone.this.name
}


resource "azurerm_subnet" "this" {
  name                 = module.naming.subnet.name_unique
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.snet_address_prefix]
}

resource "azurerm_mysql_flexible_server" "this" {
  name                              = module.naming.mysql_server.name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  administrator_login               = var.admin_username
  administrator_password_wo         = var.admin_password_wo
  administrator_password_wo_version = var.admin_password_wo_version
  sku_name                          = var.sku
  version                           = var.db_version
  # checkov:skip=CKV_AZURE_94: Geo-redundant backup is enabled conditionally via variable
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  backup_retention_days        = var.backup_retention_days
  public_network_access        = local.public_network_access

  storage {
    size_gb            = var.storage_size_gb
    iops               = var.storage_iops
    auto_grow_enabled  = var.storage_auto_grow_enabled
    io_scaling_enabled = var.storage_io_scaling_enabled
  }

  dynamic "high_availability" {
    for_each = var.ha_enabled ? [1] : []
    content {
      mode = var.ha_mode
    }
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.this]
}

resource "azurerm_private_endpoint" "default" {
  name                = module.naming.private_endpoint.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.this.id

  private_service_connection {
    name                           = "private-serviceconnection1"
    private_connection_resource_id = azurerm_mysql_flexible_server.this.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group1"
    private_dns_zone_ids = [azurerm_private_dns_zone.this.id]
  }
}

resource "azurerm_mysql_flexible_database" "this" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  charset             = var.charset
  collation           = var.collation
}
