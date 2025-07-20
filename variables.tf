variable "primary_location" {
  description = "The primary location of all resources"
  type        = string

  validation {
    condition     = length(regexall(" ", var.primary_location)) == 0
    error_message = "Location must not contain spaces"
  }
}

variable "secondary_location" {
  description = "The secondary location. setting this enables disaster recovery"
  type        = string
  default     = null

  validation {
    condition     = length(try(regexall(" ", var.secondary_location), [])) == 0
    error_message = "Location must not contain spaces"
  }

  validation {
    condition     = var.secondary_location != var.primary_location
    error_message = "Secondary location must be different from primary location"
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

variable "database_backup_retention_days" {
  description = "Backup Retention Days"
  type        = number
  default     = 1
}

variable "database_geo_redundant_backup_enabled" {
  description = "Enable Geo-Redundant Backup for MySQL Server"
  type        = bool
  default     = false
}

variable "database_ha_enabled" {
  description = "Enable Zone Redundant High Availability for MySQL Server"
  type        = bool
  default     = false
}

variable "database_storage_size_gb" {
  description = "Database Storage Size (GB)"
  type        = number
  default     = null
}

variable "database_storage_auto_grow_enabled" {
  description = "Enable Storage Auto Grow"
  type        = bool
  default     = false
}

variable "database_storage_io_scaling_enabled" {
  description = "Enable Storage I/O Scaling"
  type        = bool
  default     = false
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

variable "asp_zone_balancing_enabled" {
  description = "Enable Zone Balancing for Service Plan"
  type        = bool
  default     = false
}

variable "asp_autoscaling_enabled" {
  description = "Enable Autoscaling for Service Plan"
  type        = bool
  default     = false
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

# Front Door

variable "frontdoor_sku" {
  description = "SKU of Front Door"
  type        = string
}
