locals {
  naming_suffix                = ["db"]
  pe_naming_suffix             = ["pe"]
  dns_zone_name                = "privatelink.mysql.database.azure.com"
  geo_redundant_backup_enabled = true
  public_network_access        = "Disabled"
}
