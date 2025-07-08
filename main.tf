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

data "azurerm_client_config" "current" {}


module "vault" {
  source              = "git::https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault.git?ref=2dd068b"
  name                = module.naming.key_vault.name_unique
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = var.vault_sku
  # enable_telemetry              = var.enable_telemetry
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = true
  secrets = {
    db_pass = {
      name = "database-admin-password"
    }
  }
  secrets_value = {
    db_pass = resource.random_password.db.result
  }
  role_assignments = {
    deployment_user_kv_admin = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }
  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }
  # network_acls = {
  #   bypass   = "AzureServices"
  #   ip_rules = ["${data.http.ip.response_body}/32"]
  # }
}


ephemeral "azurerm_key_vault_secret" "db_pass" {
  name         = "database-admin-password"
  key_vault_id = module.vault.resource_id
}

module "database" {
  source                       = "./modules/database"
  extra_naming_suffix          = local.extra_naming_suffix
  location                     = azurerm_resource_group.this.location
  resource_group_name          = azurerm_resource_group.this.name
  vnet_id                      = azurerm_virtual_network.this.id
  vnet_name                    = azurerm_virtual_network.this.name
  snet_address_prefix          = cidrsubnet(local.vnet_cidr, 8, 1)
  sku                          = var.database_sku
  db_version                   = var.database_version
  backup_retention_days        = var.database_backup_retention_days
  admin_username               = var.database_admin_username
  admin_password_wo            = ephemeral.azurerm_key_vault_secret.db_pass.value
  admin_password_wo_version    = local.db_password_version
  db_name                      = var.database_name
}

module "backend" {
  source              = "./modules/backend"
  extra_naming_suffix = local.extra_naming_suffix
  location            = azurerm_resource_group.this.location
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
    # "SPRING_DATASOURCE_PASSWORD" = ephemeral.azurerm_key_vault_secret.db_pass.value
    "SERVER_PORT" = var.backend_port
  }
}

module "frontend" {
  source              = "./modules/frontend"
  extra_naming_suffix = local.extra_naming_suffix
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.frontend_sku
  worker_count        = var.frontend_worker_count
  docker_registry_url = var.frontend_docker_registry_url
  docker_image_name   = var.frontend_docker_image_name
  docker_image_tag    = var.frontend_docker_image_tag
}
