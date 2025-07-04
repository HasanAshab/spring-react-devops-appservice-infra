locals {
  project_name        = "three-tier-app"
  vnet_cidr           = "10.254.0.0/16"
  extra_naming_suffix = [local.project_name, terraform.workspace, var.location]
}
