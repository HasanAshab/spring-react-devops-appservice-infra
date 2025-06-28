output "app_url" {
  value = "https://${module.app.name}.${local.dns_zone_name}:${var.app_port}"
}

output "web_url" {
  value = module.web.url
}