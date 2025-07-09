locals {
  naming_suffix                = ["db"]
  dns_zone_name                = "privatelink.mysql.database.azure.com"
  geo_redundant_backup_enabled = true
  public_network_access        = "Disabled"
}
