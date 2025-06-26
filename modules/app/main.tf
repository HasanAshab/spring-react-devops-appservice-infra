resource "azurerm_subnet" "main" {
  name                 = "snet-app-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.snet_address_prefix]
}

resource "azurerm_service_plan" "main" {
  name                = "sp-app-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku
  worker_count        = var.worker_count
}

resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id
  app_settings        = var.app_settings
  public_network_access_enabled = false

  site_config {
    application_stack {
      docker_registry_url = var.docker_registry_url
      docker_image_name   = "${var.docker_image_name}:${var.docker_image_tag}"
    }
  }
}

resource "azurerm_private_endpoint" "app" {
  name                = "pe-app-${var.project_name}-${terraform.workspace}-${var.location}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.main.id

  private_service_connection {
    name                           = "default"
    private_connection_resource_id = azurerm_linux_web_app.main.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}