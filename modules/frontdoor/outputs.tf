output "resource_uri" {
  description = "Front Door Resource URI"
  value       = azurerm_cdn_frontdoor_endpoint.this.host_name
}

output "resource_guid" {
  description = "Front Door Resource GUID"
  value       = azurerm_cdn_frontdoor_profile.this.resource_guid
}
