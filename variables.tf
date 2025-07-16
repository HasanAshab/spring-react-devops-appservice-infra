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

variable "database_admin_password" {
  description = "Database Admin Password"
  type        = string
  sensitive   = true
}

# App Service Plan

variable "asp_os_type" {
  description = "OS Type of Service Plan"
  type        = string
  default     = "Linux"
}

variable "asp_sku" {
  description = "SKU of Service Plan"
  type        = string
}

variable "asp_worker_count" {
  description = "Number of Workers"
  type        = number
}

variable "asp_enable_zone_balancing" {
  description = "Enable Zone Balancing for Service Plan"
  type        = bool
}

variable "asp_enable_autoscale" {
  description = "Enable Autoscale for Service Plan"
  type        = bool
}

variable "asp_autoscale_minimum_capacity" {
  description = "Minimum Capacity for Autoscale"
  type        = number
  default     = null
}

variable "asp_autoscale_maximum_capacity" {
  description = "Maximum Capacity for Autoscale"
  type        = number
  default     = null
}

variable "asp_autoscale_default_capacity" {
  description = "Default Capacity for Autoscale"
  type        = number
  default     = null
}


# Backend

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
