module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming.git?ref=75d5afa" # v0.4.2
  suffix = [local.project_name, terraform.workspace, var.location]
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.vnet_cidr]
}

resource "random_password" "db" {
  length           = 12
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "vault" {
  source              = "./modules/vault"
  enable_telemetry    = var.enable_telemetry
  extra_naming_suffix = local.extra_naming_suffix
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.vault_sku
  vnet_id             = azurerm_virtual_network.this.id
  vnet_name           = azurerm_virtual_network.this.name
  snet_address_prefix = cidrsubnet(local.vnet_cidr, 10, 0)
  secrets = {
    db_pass = {
      name = "database-admin-password"
    }
  }
  secrets_value = {
    db_pass = resource.random_password.db.result
  }
  role = "Key Vault Administrator"
}


ephemeral "azurerm_key_vault_secret" "db_pass" {
  name         = "database-admin-password"
  key_vault_id = module.vault.resource_id
}

module "database" {
  source                    = "./modules/database"
  extra_naming_suffix       = local.extra_naming_suffix
  location                  = azurerm_resource_group.this.location
  resource_group_name       = azurerm_resource_group.this.name
  vnet_id                   = azurerm_virtual_network.this.id
  vnet_name                 = azurerm_virtual_network.this.name
  snet_address_prefix       = cidrsubnet(local.vnet_cidr, 10, 1)
  sku                       = var.database_sku
  db_version                = var.database_version
  backup_retention_days     = var.database_backup_retention_days
  admin_username            = var.database_admin_username
  admin_password_wo         = "Passr@sadad.1213" # ephemeral.azurerm_key_vault_secret.db_pass.value
  admin_password_wo_version = local.db_password_version
  db_name                   = var.database_name
}

module "backend" {
  source              = "./modules/backend"
  extra_naming_suffix = local.extra_naming_suffix
  enable_telemetry    = var.enable_telemetry
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  vnet_name           = azurerm_virtual_network.this.name
  snet_address_prefix = cidrsubnet(local.vnet_cidr, 10, 2)
  sku                 = var.backend_sku
  worker_count        = var.backend_worker_count
  docker_registry_url = var.backend_docker_registry_url
  docker_image_name   = var.backend_docker_image_name
  docker_image_tag    = var.backend_docker_image_tag
  port                = var.backend_port
  db_host             = module.database.fqdn
  db_name             = var.database_name
  db_username         = var.database_admin_username
  db_password         = "Passr@sadad.1213" # ephemeral.azurerm_key_vault_secret.db_pass.value
}

module "frontend" {
  source              = "./modules/frontend"
  extra_naming_suffix = local.extra_naming_suffix
  enable_telemetry    = var.enable_telemetry
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.frontend_sku
  worker_count        = var.frontend_worker_count
  docker_registry_url = var.frontend_docker_registry_url
  docker_image_name   = var.frontend_docker_image_name
  docker_image_tag    = var.frontend_docker_image_tag
}
