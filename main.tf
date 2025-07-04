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


ephemeral "random_password" "db" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "vault" {
  source              = "./modules/vault"
  name                = module.naming.key_vault.name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.vault_sku
  secrets = {
    db_pass = {
      name    = "database-admin-password"
      version = local.db_password_version
    }
  }
  secrets_value = {
    db_pass = ephemeral.random_password.db.result
  }
}

module "database" {
  source                    = "./modules/database"
  extra_naming_suffix       = local.extra_naming_suffix
  location                  = var.location
  resource_group_name       = azurerm_resource_group.this.name
  vnet_id                   = azurerm_virtual_network.this.id
  vnet_name                 = azurerm_virtual_network.this.name
  snet_address_prefix       = cidrsubnet(local.vnet_cidr, 8, 1)
  sku                       = var.database_sku
  db_version                = var.database_version
  admin_username            = var.database_admin_username
  admin_password_wo         = module.vault.secrets["db_pass"].value
  admin_password_wo_version = local.db_password_version
  db_name                   = var.database_name
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
    "SPRING_DATASOURCE_USERNAME" = var.database_admin_username
    "SPRING_DATASOURCE_PASSWORD" = module.vault.secrets["db_pass"].value # todo
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