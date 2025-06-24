# output "web_url" {
#   value = module.web.url
# }

output "app_private_host" {
  value = "http://${module.app.name}.${local.dns_zone_name}"
}