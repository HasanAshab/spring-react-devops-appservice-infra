module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming.git?ref=75d5afa" # v0.4.2
  suffix = concat(local.naming_suffix, var.extra_naming_suffix)
}

resource "azurerm_subnet" "this" {
  name                 = module.naming.subnet.name_unique
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.snet_address_prefix]
  virtual_network_name = var.vnet_name
  delegation {
    name = "webapp"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

module "webapp" {
  source                      = "git::https://github.com/Azure/terraform-azurerm-avm-res-web-site.git?ref=5388703" # v0.17.2
  kind                        = "webapp"
  os_type                     = var.os_type
  enable_telemetry            = var.enable_telemetry
  enable_application_insights = var.enable_application_insights
  name                        = module.naming.app_service.name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  service_plan_resource_id    = var.asp_id
  virtual_network_subnet_id   = azurerm_subnet.this.id
  https_only                  = local.https_only
  tags                        = var.tags
  deployment_slots = var.enable_blue_green_deployment ? {
    staging = {
      name = "staging"
      site_config = {
        application_stack = {
          docker = {
            docker_registry_url = var.docker_registry_url
            docker_image_name   = "${var.docker_image_name}:${var.docker_image_tag}"
          }
        }
      }
    }
  } : {}
  app_settings = {
    WEBSITES_PORT              = var.port
    SPRING_DATASOURCE_URL      = "jdbc:mysql://${var.db_host}:3306/${var.db_name}?allowPublicKeyRetrieval=true&useSSL=true&createDatabaseIfNotExist=true&useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=Europe/Paris"
    SPRING_DATASOURCE_USERNAME = var.db_username
    SPRING_DATASOURCE_PASSWORD = var.db_password
  }
  site_config = {
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min
    ftps_state                        = local.ftps_state
    vnet_route_all_enabled            = local.vnet_route_all_enabled
    application_stack = {
      docker = {
        docker_registry_url = var.docker_registry_url
        docker_image_name   = "${var.docker_image_name}:${var.docker_image_tag}"
      }
    }
  }
}
