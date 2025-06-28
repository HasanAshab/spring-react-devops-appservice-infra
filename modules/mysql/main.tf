resource "azurerm_subnet" "this" {
  name                 = "snet-mysql-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.snet_address_prefix]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_mysql_flexible_server" "this" {
  name                   = "mysql-${var.project_name}-${terraform.workspace}-${var.location}-001"
  location               = var.location
  resource_group_name    = var.resource_group_name
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  sku_name               = var.sku
  version                = var.db_version

  geo_redundant_backup_enabled = false
  delegated_subnet_id          = azurerm_subnet.this.id
  storage {
    size_gb = 20
  }
}

resource "azurerm_mysql_flexible_database" "this" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "this" {
  name                = "allow-all"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# resource "azurerm_private_endpoint" "mysql" {
#   name                = "pe-mysql-${var.project_name}-${terraform.workspace}-${var.location}-001"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = azurerm_subnet.this.id

#   private_service_connection {
#     name                           = "mysql-connection"
#     private_connection_resource_id = azurerm_mysql_flexible_server.this.id
#     subresource_names              = ["mysqlServer"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "default"
#     private_dns_zone_ids = [ var.private_dns_zone_id ]
#   }
# }
