resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [ var.sn_address_prefix ]
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_bastion_host" "main" {
  name                = "bastion-${var.project_name}-${terraform.workspace}-${var.location}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                 = "bastion-ip-configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}