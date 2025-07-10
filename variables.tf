variable "location" {
  description = "Location of all resources"
  type        = string

  validation {
    condition     = length(regexall(" ", var.location)) == 0
    error_message = "Location must not contain spaces"
  }
}

variable "enable_telemetry" {
  description = "Enable Telemetry for all modules"
  type        = bool
  default     = true
}

# Vault
variable "vault_sku" {
  description = "SKU of Key Vault"
  type        = string
}

# Database
variable "database_sku" {
  description = "SKU of MySQL Server"
  type        = string
}

variable "database_version" {
  description = "Version of MySQL Server"
  type        = string
}

variable "database_backup_retention_days" {
  description = "Backup Retention Days"
  type        = number
}

variable "database_name" {
  description = "Database Name"
  type        = string
}

variable "database_admin_username" {
  description = "Database Admin Username"
  type        = string
}

# Backend
variable "backend_sku" {
  description = "SKU of VM-Scale Set"
  type        = string
}

variable "backend_worker_count" {
  description = "Number of Workers"
  type        = number
}

variable "backend_docker_registry_url" {
  description = "Docker Registry URL"
  type        = string
}

variable "backend_docker_image_name" {
  description = "Docker Image Name"
  type        = string
}

variable "backend_docker_image_tag" {
  description = "Docker Image Tag"
  type        = string
}

variable "backend_port" {
  description = "Port of Backend App"
  type        = string
  default     = "80"
}

# Frontend
variable "frontend_sku" {
  description = "SKU of VM-Scale Set"
  type        = string
}

variable "frontend_worker_count" {
  description = "Number of Workers"
  type        = number
}

variable "frontend_docker_registry_url" {
  description = "Docker Registry URL"
  type        = string
}

variable "frontend_docker_image_name" {
  description = "Docker Image Name"
  type        = string
}

variable "frontend_docker_image_tag" {
  description = "Docker Image Tag"
  type        = string
}

variable "foo" {
  default = "bar"
}
