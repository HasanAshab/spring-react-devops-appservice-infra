module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming.git?ref=75d5afa" # v0.4.2
  suffix = concat(local.naming_suffix, var.extra_naming_suffix)
}

module "webapp" {
  source                   = "git::https://github.com/Azure/terraform-azurerm-avm-res-web-site.git?ref=5388703" # v0.17.2
  kind                     = "webapp"
  os_type                  = var.os_type
  enable_telemetry         = var.enable_telemetry
  name                     = module.naming.app_service.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  service_plan_resource_id = var.asp_id
  https_only               = local.https_only
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
