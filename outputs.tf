output "app_url" {
  description = "Backend App URL"
  value       = "${module.app.url}:${var.app_port}"
}

output "web_url" {
  description = "Frontend Web URL"
  value       = module.web.url
}