resource "azurerm_resource_group" "main" {
  name     = "rg-${local.project_name}-${terraform.workspace}"
  location = var.location
  tags = {
    Environment = terraform.workspace
    Service     = local.project_name
  }
}

module "vnet" {
  source              = "./modules/vnet"
  name                = "vnet-${local.project_name}-${terraform.workspace}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.254.0.0/16"]
}

# resource "azurerm_application_gateway" "name" {
#   name                = "appgw-${local.project_name}-${terraform.workspace}-001"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location

#   sku {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 2
#   }

# }