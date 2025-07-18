module "naming" {
  for_each = local.locations
  source   = "git::https://github.com/Azure/terraform-azurerm-naming.git?ref=75d5afa" # v0.4.2
  suffix   = [local.project_name, terraform.workspace, each.key]
}

resource "azurerm_resource_group" "this" {
  for_each = local.locations
  name     = module.naming[each.key].resource_group.name
  location = each.key
}

resource "azurerm_virtual_network" "this" {
  for_each            = local.locations
  name                = module.naming[each.key].virtual_network.name
  location            = azurerm_resource_group.this[each.key].location
  resource_group_name = azurerm_resource_group.this[each.key].name
  address_space       = [local.vnet_cidr]
}

module "database" {
  source                      = "./modules/database"
  extra_naming_suffix         = local.extra_naming_suffixes[var.primary_location]
  location                    = azurerm_resource_group.this[var.primary_location].location
  resource_group_name         = azurerm_resource_group.this[var.primary_location].name
  vnet_id                     = azurerm_virtual_network.this[var.primary_location].id
  vnet_name                   = azurerm_virtual_network.this[var.primary_location].name
  snet_address_prefix         = cidrsubnet(local.vnet_cidr, 10, 0)
  sku                         = var.database_sku
  db_version                  = var.database_version
  enable_geo_redundant_backup = var.database_enable_geo_redundant_backup
  backup_retention_days       = var.database_backup_retention_days
  admin_username              = var.database_admin_username
  admin_password_wo           = var.database_admin_password
  admin_password_wo_version   = local.db_password_version
  db_name                     = var.database_name
}

module "asp" {
  for_each              = local.locations
  source                = "./modules/asp"
  naming_suffix         = local.extra_naming_suffixes[each.key]
  resource_group_name   = azurerm_resource_group.this[each.key].name
  location              = azurerm_resource_group.this[each.key].location
  os_type               = var.asp_os_type
  sku                   = var.asp_sku
  worker_count          = var.asp_worker_count
  enable_zone_balancing = var.asp_enable_zone_balancing
  autoscale_settings = {
    enabled          = var.asp_enable_autoscale
    default_capacity = var.asp_autoscale_default_capacity
    minimum_capacity = var.asp_autoscale_minimum_capacity
    maximum_capacity = var.asp_autoscale_maximum_capacity
    rules = [
      {
        metric_trigger = {
          metric_name      = "CpuPercentage"
          time_grain       = "PT1M"
          statistic        = "Average"
          time_window      = "PT5M"
          time_aggregation = "Average"
          operator         = "GreaterThan"
          threshold        = 80
        }
        scale_action = {
          direction = "Increase"
          type      = "ChangeCount"
          value     = "1"
          cooldown  = "PT5M"
        }
      },
      {
        metric_trigger = {
          metric_name      = "CpuPercentage"
          time_grain       = "PT1M"
          statistic        = "Average"
          time_window      = "PT5M"
          time_aggregation = "Average"
          operator         = "LessThan"
          threshold        = 25
        }
        scale_action = {
          direction = "Decrease"
          type      = "ChangeCount"
          value     = "1"
          cooldown  = "PT5M"
        }
      }
    ]
  }
}

module "backend" {
  for_each            = local.locations
  source              = "./modules/backend"
  extra_naming_suffix = local.extra_naming_suffixes[each.key]
  enable_telemetry    = var.enable_telemetry
  location            = azurerm_resource_group.this[each.key].location
  resource_group_name = azurerm_resource_group.this[each.key].name
  os_type             = var.asp_os_type
  asp_id              = module.asp[each.key].resource_id
  vnet_name           = azurerm_virtual_network.this[each.key].name
  snet_address_prefix = cidrsubnet(local.vnet_cidr, 10, 1)
  docker_registry_url = var.backend_docker_registry_url
  docker_image_name   = var.backend_docker_image_name
  docker_image_tag    = var.backend_docker_image_tag
  port                = var.backend_port
  db_host             = module.database.fqdn
  db_name             = var.database_name
  db_username         = var.database_admin_username
  db_password         = var.database_admin_password
  depends_on          = [module.database]
}

module "frontend" {
  for_each            = local.locations
  source              = "./modules/frontend"
  extra_naming_suffix = local.extra_naming_suffixes[each.key]
  enable_telemetry    = var.enable_telemetry
  location            = azurerm_resource_group.this[each.key].location
  resource_group_name = azurerm_resource_group.this[each.key].name
  os_type             = var.asp_os_type
  asp_id              = module.asp[each.key].resource_id
  docker_registry_url = var.frontend_docker_registry_url
  docker_image_name   = var.frontend_docker_image_name
  docker_image_tag    = var.frontend_docker_image_tag
}

# module "frontdoor" {
#   source = "./modules/frontdoor"
#   resource_group_name = azurerm_resource_group.this[var.primary_location].name
#   sku         = "Standard_AzureFrontDoor"
#   origins = [
#     {
#       name      = "frontend"

#       host_name = module.frontend[var.primary_location].fqdn

#     }


#   ]
# }
