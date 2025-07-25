locals {
  project_name          = "three-tier-app"
  vnet_cidr             = "10.254.0.0/16"
  locations             = toset(compact([var.primary_location, var.secondary_location]))
  extra_naming_suffixes = { for l in local.locations : l => [local.project_name, terraform.workspace, l] }
  db_password_version   = 1
}
