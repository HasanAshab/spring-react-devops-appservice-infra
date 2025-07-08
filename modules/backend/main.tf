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
  source                    = "Azure/avm-res-web-site/azurerm"
  version                   = "0.17.2"
  kind                      = "webapp"
  os_type                   = local.os_type
  name                      = module.naming.app_service.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  service_plan_resource_id  = module.asp.resource_id
  app_settings              = var.app_settings
  virtual_network_subnet_id = azurerm_subnet.this.id
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

# resource "azurerm_subnet" "pe" {
#   name                 = "snet-pe-${var.project_name}-${terraform.workspace}-${var.location}-001"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = var.vnet_name
#   address_prefixes     = ["10.254.4.0/24"]

#   private_endpoint_network_policies = "Enabled"
# }

# resource "azurerm_private_endpoint" "app" {
#   name                = "pe-app-${var.project_name}-${terraform.workspace}-${var.location}-001"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = azurerm_subnet.pe.id

#   private_service_connection {
#     name                           = "default"
#     private_connection_resource_id = azurerm_linux_web_app.this.id
#     subresource_names              = ["sites"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "default"
#     private_dns_zone_ids = [var.private_dns_zone_id]
#   }
# }
