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

resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network.name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.vnet_cidr]
}

module "database" {
  source              = "./modules/database"
  extra_naming_suffix = local.extra_naming_suffix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  vnet_id             = azurerm_virtual_network.this.id
  vnet_name           = azurerm_virtual_network.this.name
  snet_address_prefix = cidrsubnet(local.vnet_cidr, 8, 1)
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
  vnet_name           = azurerm_virtual_network.this.name
  snet_address_prefix = cidrsubnet(local.vnet_cidr, 8, 2)
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