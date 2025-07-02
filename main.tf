resource "azurerm_resource_group" "this" {
  name     = "rg-${local.project_name}-${terraform.workspace}"
  location = var.location
  tags = {
    Environment = terraform.workspace
    Service     = local.project_name
  }
}

module "network" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.9.1"
  address_space       = [local.vnet_cidr]
  location            = var.location
  name                = "vnet-${local.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name = azurerm_resource_group.this.name
  subnets = {
    mysql = {
      name              = "mysql"
      address_prefixes  = [cidrsubnet(local.vnet_cidr, 8, 1)]
      service_endpoints = ["Microsoft.Storage"]
      delegations = [
        {
          name = "fs"
          service_delegation = {
            name    = "Microsoft.DBforMySQL/flexibleServers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      ]
    }
    app = {
      name             = "app"
      address_prefixes = [cidrsubnet(local.vnet_cidr, 8, 2)]
      delegations = [
        {
          name = "webapp"
          service_delegation = {
            name    = "Microsoft.Web/serverFarms"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
          }
        }
      ]
    }
  }

  tags = {
    Environment = terraform.workspace
    Service     = local.project_name
  }
}

module "dns_db" {
  source              = "./modules/dns"
  name                = local.db_dns_zone_name
  resource_group_name = azurerm_resource_group.this.name
  vnet_id             = module.network.resource_id
}

module "mysql" {
  source              = "./modules/mysql"
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  snet_id             = module.network.subnets["mysql"].id
  private_dns_zone_id = module.dns_db.zone_id
  sku                 = var.mysql_sku
  db_version          = var.mysql_version
  admin_username      = local.mysql_admin_username
  admin_password      = local.mysql_admin_password
  db_name             = var.mysql_db_name
}

module "app" {
  source              = "./modules/app"
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  snet_id             = module.network.subnets["app"].id
  private_dns_zone_id = 1 #TODO remove
  sku                 = var.app_sku
  worker_count        = var.app_worker_count
  docker_registry_url = var.app_docker_registry_url
  docker_image_name   = var.app_docker_image_name
  docker_image_tag    = var.app_docker_image_tag
  app_settings = {
    "SPRING_DATASOURCE_URL"      = "jdbc:mysql://${module.mysql.fqdn}:3306/${var.mysql_db_name}?allowPublicKeyRetrieval=true&useSSL=true&createDatabaseIfNotExist=true&useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=Europe/Paris"
    "SPRING_DATASOURCE_USERNAME" = local.mysql_admin_username
    "SPRING_DATASOURCE_PASSWORD" = local.mysql_admin_password
    "SERVER_PORT"                = var.app_port
  }
}

module "web" {
  source              = "./modules/web"
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.web_sku
  worker_count        = var.web_worker_count
  docker_registry_url = var.web_docker_registry_url
  docker_image_name   = var.web_docker_image_name
  docker_image_tag    = var.web_docker_image_tag
}
