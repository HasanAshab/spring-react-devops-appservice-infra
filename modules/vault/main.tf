data "azurerm_client_config" "current" {}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming.git?ref=75d5afa" # v0.4.2
  suffix = concat(local.naming_suffix, var.extra_naming_suffix)
}

resource "azurerm_private_dns_zone" "this" {
  name                = local.dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "dns-link"
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
  private_dns_zone_name = azurerm_private_dns_zone.this.name
}

resource "azurerm_subnet" "this" {
  name                 = module.naming.subnet.name_unique
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.snet_address_prefix]
  virtual_network_name = var.vnet_name
}

module "vault" {
  source                        = "git::https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault.git?ref=2dd068b"
  enable_telemetry              = var.enable_telemetry
  name                          = module.naming.key_vault.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku_name                      = var.sku
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = local.public_network_access_enabled
  secrets                       = var.secrets
  secrets_value                 = var.secrets_value
  role_assignments = {
    deployment_user_kv_admin = {
      role_definition_id_or_name = var.role
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }
  private_endpoints = {
    primary = {
      subnet_resource_id = azurerm_subnet.this.id
      private_dns_zone_resource_ids = [
        azurerm_private_dns_zone.this.id
      ]
    }
  }
}
