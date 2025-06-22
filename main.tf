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
  project_name = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.254.0.0/16"]
}

module "appgw" {
  source              = "./modules/appgw"
  project_name = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  vnet_name           = module.vnet.name
  sku_tier = "Standard_v2"
  capacity = 2
}
