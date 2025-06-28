resource "azurerm_subnet" "this" {
  name                 = "snet-app-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.snet_address_prefix]

  delegation {
    name = "webapp-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_service_plan" "this" {
  name                = "sp-app-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku
  worker_count        = var.worker_count
}

resource "azurerm_linux_web_app" "this" {
  name                          = "app-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  service_plan_id               = azurerm_service_plan.this.id
  app_settings                  = var.app_settings
  public_network_access_enabled = true
  virtual_network_subnet_id     = azurerm_subnet.this.id

  site_config {
    application_stack {
      docker_registry_url = var.docker_registry_url
      docker_image_name   = "${var.docker_image_name}:${var.docker_image_tag}"
    }
  }
}

# resource "azurerm_subnet" "pe" {
#   name                 = "snet-pe-${var.project_name}-${terraform.workspace}-${var.location}-001"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = var.vnet_name
#   address_prefixes     = ["10.254.4.0/24"]
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