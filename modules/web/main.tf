resource "azurerm_subnet" "main" {
  name                 = "snet-web-${var.project_name}-${terraform.workspace}-${var.location}-001"
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

resource "azurerm_service_plan" "main" {
  name                = "sp-web-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku
  worker_count        = var.worker_count
}

resource "azurerm_linux_web_app" "main" {
  name                = "web-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id
  app_settings        = var.app_settings

  site_config {
    application_stack {
      docker_registry_url = var.docker_registry_url
      docker_image_name   = "${var.docker_image_name}:${var.docker_image_tag}"
    }
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = azurerm_subnet.main.id
}