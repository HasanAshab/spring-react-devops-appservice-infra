module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = concat(local.naming_suffix, var.extra_naming_suffix)
}

module "asp" {
  source                 = "Azure/avm-res-web-serverfarm/azurerm"
  version                = "0.7.0"
  name                   = module.naming.app_service_plan.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  os_type                = local.os_type
  sku_name               = var.sku
  worker_count           = var.worker_count
  zone_balancing_enabled = false
}

module "webapp" {
  source                   = "Azure/avm-res-web-site/azurerm"
  version                  = "0.17.2"
  kind                     = "webapp"
  os_type                  = local.os_type
  name                     = module.naming.app_service.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  service_plan_resource_id = module.asp.resource_id
  app_settings             = var.app_settings
  # virtual_network_subnet_id = var.snet_id
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
