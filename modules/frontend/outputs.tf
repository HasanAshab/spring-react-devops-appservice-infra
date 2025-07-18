output "url" {
  value = "https://${module.webapp.resource_uri}"
}

output "resource_uri" {
  value = module.webapp.resource_uri
}
