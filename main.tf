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
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [ local.vnet_cidr ]
}

module "appgw" {
  source              = "./modules/appgw"
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  vnet_name           = module.vnet.name
  sn_address_prefix   = cidrsubnet(local.vnet_cidr, 8, 0)
  sku_tier            = var.appgw_sku
  port                = var.appgw_port
  capacity            = var.web_instances
}

module "vmss_web" {
  source                   = "./modules/vmss"
  project_name             = local.project_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.main.name
  vnet_name                = module.vnet.name
  sn_address_prefix        = cidrsubnet(local.vnet_cidr, 8, 1)
  sku                      = var.web_sku
  instances                = var.web_instances
  image_offer              = var.web_image_offer
  image_sku                = var.web_image_sku
  admin_username           = "adminuser"
  public_key_path          = var.web_public_key_path
  backend_address_pool_ids = module.appgw.backend_address_pool_ids
  custom_data       = base64encode(templatefile("${path.module}/bin/web-init.sh", {
    backend_ip   = module.vmss_app.private_ip
    backend_port = local.app_backend_port
  })
}


module "vmss_app" {
  source                   = "./modules/vmss"
  project_name             = local.project_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.main.name
  vnet_name                = module.vnet.name
  sn_address_prefix        = cidrsubnet(local.vnet_cidr, 8, 1)
  sku                      = var.web_sku
  instances                = var.web_instances
  image_offer              = var.web_image_offer
  image_sku                = var.web_image_sku
  admin_username           = "adminuser"
  public_key_path          = var.web_public_key_path
  backend_address_pool_ids = module.appgw.backend_address_pool_ids
  custom_data       = base64encode(templatefile("${path.module}/bin/web-init.sh", {
    backend_ip   = var.backend_ip
    backend_port = var.backend_port
  })
}


module "bastion" {
  source              = "./modules/bastion"
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  vnet_name           = module.vnet.name
  sn_address_prefix   = cidrsubnet(local.vnet_cidr, 11, 510)
}