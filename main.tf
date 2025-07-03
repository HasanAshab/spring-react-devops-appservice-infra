module "vault" {
  source              = "./modules/vault"
  name                = local.vault_name
  resource_group_name = local.vault_resource_group
  secrets = [
    "database-admin-username",
    "database-admin-password",
  ]
}

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
      name              = module.naming.subnet.name_unique
      address_prefixes  = [cidrsubnet(local.vnet_cidr, 8, 1)]
      service_endpoints = ["Microsoft.Storage"]
      delegation = [{
        name = "fs"
        service_delegation = {
          name    = "Microsoft.DBforMySQL/flexibleServers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }]
    }
    backend = {
      name             = module.naming.subnet.name_unique
      address_prefixes = [cidrsubnet(local.vnet_cidr, 8, 2)]
      delegation = [{
        name = "webapp"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }]
    }
  }

  tags = {
    Environment = terraform.workspace
    Service     = local.project_name
  }
}

module "database" {
  source              = "./modules/database"
  extra_naming_suffix = local.extra_naming_suffix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  vnet_id             = module.network.resource_id
  snet_id             = module.network.subnets["database"].resource_id
  sku                 = var.database_sku
  db_version          = var.database_version
  admin_username      = module.vault.secrets["database-admin-username"]
  admin_password      = module.vault.secrets["database-admin-password"]
  db_name             = var.database_name
}

module "backend" {
  source              = "./modules/backend"
  extra_naming_suffix = local.extra_naming_suffix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  snet_id             = module.network.subnets["backend"].resource_id
  sku                 = var.backend_sku
  worker_count        = var.backend_worker_count
  docker_registry_url = var.backend_docker_registry_url
  docker_image_name   = var.backend_docker_image_name
  docker_image_tag    = var.backend_docker_image_tag
  app_settings = {
    "SPRING_DATASOURCE_URL"      = "jdbc:mysql://${module.database.fqdn}:3306/${var.database_name}?allowPublicKeyRetrieval=true&useSSL=true&createDatabaseIfNotExist=true&useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=Europe/Paris"
    "SPRING_DATASOURCE_USERNAME" = module.vault.secrets["database-admin-username"]
    "SPRING_DATASOURCE_PASSWORD" = module.vault.secrets["database-admin-password"]
    "SERVER_PORT"                = var.backend_port
  }
}

module "frontend" {
  source              = "./modules/frontend"
  extra_naming_suffix = local.extra_naming_suffix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.frontend_sku
  worker_count        = var.frontend_worker_count
  docker_registry_url = var.frontend_docker_registry_url
  docker_image_name   = var.frontend_docker_image_name
  docker_image_tag    = var.frontend_docker_image_tag
}