output "app_url" {
  description = "Backend App URL"
  value       = module.app.url
}

output "web_url" {
  description = "Frontend Web URL"
  value       = module.web.url
}