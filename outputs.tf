output "backend_url" {
  description = "Backend App URL"
  value       = module.backend.url
}

output "frontend_url" {
  description = "Frontend Web URL"
  value       = module.frontend.url
}
