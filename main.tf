module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [local.project_name, terraform.workspace, var.location]
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network.name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.vnet_cidr]
}

data "azurerm_client_config" "current" {}

ephemeral "random_password" "username" {
  length           = 16
  special          = false
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

ephemeral "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "vault" {
  source              = "./modules/vault"
  name                = module.vault.name
  resource_group_name = azurerm_resource_group.this.name
  secrets = [
    {
      name             = "database-admin-username"
      value_wo         = ephemeral.random_password.username.value
      value_wo_version = 1
    },
    {
      name             = "database-admin-password"
      value            = ephemeral.random_password.password.value
      value_wo_version = 1
    }
  ]
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