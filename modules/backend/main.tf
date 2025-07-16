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
  source                    = "git::https://github.com/Azure/terraform-azurerm-avm-res-web-site.git?ref=5388703" # v0.17.2
  kind                      = "webapp"
  os_type                   = local.os_type
  enable_telemetry          = var.enable_telemetry
  name                      = module.naming.app_service.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  service_plan_resource_id  = var.asp_id
  virtual_network_subnet_id = azurerm_subnet.this.id
  app_settings = {
    SERVER_PORT                = var.port
    SPRING_DATASOURCE_URL      = "jdbc:mysql://${var.db_host}:3306/${var.db_name}?allowPublicKeyRetrieval=true&useSSL=true&createDatabaseIfNotExist=true&useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=Europe/Paris"
    SPRING_DATASOURCE_USERNAME = var.db_username
    SPRING_DATASOURCE_PASSWORD = var.db_password
  }
  site_config = {
    vnet_route_all_enabled = true
    application_stack = {
      docker = {
        docker_registry_url = var.docker_registry_url
        docker_image_name   = "${var.docker_image_name}:${var.docker_image_tag}"
      }
    }
  }
}
