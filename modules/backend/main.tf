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
  # source  = "Azure/avm-res-web-site/azurerm"
  # version = "0.17.2"
  source                    = "git::https://github.com/Azure/terraform-azurerm-avm-res-web-site.git?ref=5388703" # v0.17.2
  kind                      = "webapp"
  os_type                   = var.os_type
  enable_telemetry          = var.enable_telemetry
  name                      = module.naming.app_service.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  service_plan_resource_id  = var.asp_id
  virtual_network_subnet_id = azurerm_subnet.this.id
  https_only                = local.https_only
  app_settings = {
    SERVER_PORT                = var.port
    SPRING_DATASOURCE_URL      = "jdbc:mysql://${var.db_host}:3306/${var.db_name}?allowPublicKeyRetrieval=true&useSSL=true&createDatabaseIfNotExist=true&useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=Europe/Paris"
    SPRING_DATASOURCE_USERNAME = var.db_username
    SPRING_DATASOURCE_PASSWORD = var.db_password
  }
  site_config = {
    ftps_state             = local.ftps_state
    vnet_route_all_enabled = local.vnet_route_all_enabled
    application_stack = {
      docker = {
        docker_registry_url = var.docker_registry_url
        docker_image_name   = "${var.docker_image_name}:${var.docker_image_tag}"
      }
    }
    ip_restriction = {
      allow_front_door = {
        service_tag               = "AzureFrontDoor.Backend"
        ip_address                = null
        virtual_network_subnet_id = null
        action                    = "Allow"
        priority                  = 100
        headers = {
          front_door = {
            x_azure_fdid = [var.front_door_guid]
          }
        }
        name = "Allow traffic from Front Door"
      }
    }
  }
}
