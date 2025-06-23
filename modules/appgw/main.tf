resource "azurerm_subnet" "appgw" {
  name                 = "sn-appgw-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [ var.sn_address_prefix ]
}

resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "main" {
  name                = "appgw-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku_tier
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = var.port
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = var.backend_cookie_based_affinity
    path                  = var.backend_path
    port                  = var.backend_port
    protocol              = var.backend_protocol
    request_timeout       = var.backend_request_timeout
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = var.backend_protocol
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9 
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  tags = {
    Environment = terraform.workspace
    Service     = var.project_name
  }
}