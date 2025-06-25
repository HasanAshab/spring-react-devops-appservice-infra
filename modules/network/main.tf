resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${terraform.workspace}-${var.location}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = {
    Environment = terraform.workspace
    Service     = var.project_name
  }
}
