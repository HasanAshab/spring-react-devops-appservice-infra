module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [local.project_name, terraform.workspace, var.location]
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
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
  name                = module.naming.virtual_network.name
  resource_group_name = azurerm_resource_group.this.name
  subnets = {
    database = {
      name              = "database"
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
  name                = module.naming.private_dns_zone.name
  resource_group_name = azurerm_resource_group.this.name
  vnet_id             = module.network.resource_id
}

output "dns_name" {
  value = module.naming.private_dns_zone.name
}

module "database" {
  source              = "./modules/database"
  name                = module.naming.mysql_server.name_unique
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  snet_id             = module.network.subnets["database"].id
  private_dns_zone_id = module.dns_db.zone_id
  sku                 = var.database_sku
  db_version          = var.database_version
  admin_username      = local.database_admin_username
  admin_password      = local.database_admin_password
  db_name             = var.database_name
}

module "backend" {
  source              = "./modules/backend"
  project_name        = module.naming.app_service.name_unique
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  snet_id             = module.network.subnets["backend"].id
  private_dns_zone_id = 1 #TODO remove
  sku                 = var.backend_sku
  worker_count        = var.backend_worker_count
  docker_registry_url = var.backend_docker_registry_url
  docker_image_name   = var.backend_docker_image_name
  docker_image_tag    = var.backend_docker_image_tag
  app_settings = {
    "SPRING_DATASOURCE_URL"      = "jdbc:mysql://${module.database.fqdn}:3306/${var.database_name}?allowPublicKeyRetrieval=true&useSSL=true&createDatabaseIfNotExist=true&useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=Europe/Paris"
    "SPRING_DATASOURCE_USERNAME" = local.database_admin_username
    "SPRING_DATASOURCE_PASSWORD" = local.database_admin_password
    "SERVER_PORT"                = var.backend_port
  }
}

module "frontend" {
  source              = "./modules/frontend"
  name                = module.naming.app_service.name_unique
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.frontend_sku
  worker_count        = var.frontend_worker_count
  docker_registry_url = var.frontend_docker_registry_url
  docker_image_name   = var.frontend_docker_image_name
  docker_image_tag    = var.frontend_docker_image_tag
}
