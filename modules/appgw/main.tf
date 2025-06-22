resource "azurerm_subnet" "appgw" {
  name                 = ""
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.254.0.0/24"]
}

resource "azurerm_application_gateway" "main" {
  name                = "appgw-${local.project_name}-${terraform.workspace}-001"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = azurerm_subnet.appgw.id
  }
}