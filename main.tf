resource "azurerm_resource_group" "main" {
  name     = "rg-${local.project_name}-${terraform.workspace}"
  location = var.location
  tags = {
    Environment = terraform.workspace
    Service     = local.project_name
  }
}

module "network" {
  source              = "./modules/network"
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [local.vnet_cidr]
}

module "dns" {
  source              = "./modules/dns"
  name                = local.dns_zone_name
  resource_group_name = azurerm_resource_group.main.name
  vnet_id             = module.network.id
}

module "web" {
  source              = "./modules/web"
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  vnet_name           = module.network.name
  snet_address_prefix = cidrsubnet(local.vnet_cidr, 8, 0)
  sku                 = var.web_sku
  worker_count        = var.web_worker_count
  docker_registry_url = var.web_docker_registry_url
  docker_image_name   = var.web_docker_image_name
  docker_image_tag    = var.web_docker_image_tag
}

module "app" {
  source              = "./modules/app"
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  vnet_name           = module.network.name
  snet_address_prefix = cidrsubnet(local.vnet_cidr, 8, 1)
  sku                 = var.app_sku
  worker_count        = var.app_worker_count
  docker_registry_url = var.app_docker_registry_url
  docker_image_name   = var.app_docker_image_name
  docker_image_tag    = var.app_docker_image_tag
  private_dns_zone_id = module.dns.zone_id
}


# module "vmss_web" {
#   source                   = "./modules/vmss"
#   project_name             = local.project_name
#   location                 = var.location
#   resource_group_name      = azurerm_resource_group.main.name
#   vnet_name                = module.vnet.name
#   snet_address_prefix        = cidrsubnet(local.vnet_cidr, 8, 1)
#   sku                      = var.web_sku
#   instances                = var.web_instances
#   image_offer              = var.web_image_offer
#   image_sku                = var.web_image_sku
#   admin_username           = "adminuser"
#   public_key_path          = var.web_public_key_path
#   backend_address_pool_ids = module.appgw.backend_address_pool_ids
#   custom_data       = base64encode(file("${path.module}/bin/web-init.sh"))
# }



# module "bastion" {
#   source              = "./modules/bastion"
#   project_name        = local.project_name
#   location            = var.location
#   resource_group_name = azurerm_resource_group.main.name
#   vnet_name           = module.vnet.name
#   snet_address_prefix   = cidrsubnet(local.vnet_cidr, 11, 510)
# }