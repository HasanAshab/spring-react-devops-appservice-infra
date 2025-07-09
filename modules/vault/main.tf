data "azurerm_client_config" "current" {}

data "http" "ip" {
  url = "https://api.ipify.org/"
  retry {
    attempts     = 5
    max_delay_ms = 1000
    min_delay_ms = 500
  }
}

module "vault" {
  source                        = "git::https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault.git?ref=2dd068b"
  enable_telemetry              = var.enable_telemetry
  name                          = var.name
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
  network_acls = {
    bypass   = "AzureServices"
    ip_rules = ["${data.http.ip.response_body}/32"]
  }
}
