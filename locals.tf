locals {
  project_name         = "three-tier-app"
  vnet_cidr            = "10.254.0.0/16"
  vault_name           = "kv-${local.project_name}-${terraform.workspace}"
  vault_resource_group = "terraform"
  extra_naming_suffix  = [local.project_name, terraform.workspace, var.location]
}
