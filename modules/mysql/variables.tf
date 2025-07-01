variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "location" {
  description = "Location of all resources"
  type        = string

  validation {
    condition     = length(regexall(" ", var.location)) == 0
    error_message = "Location must not contain spaces"
  }
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "vnet_name" {
  description = "Virtual Network Name"
  type        = string
}

variable "snet_address_prefix" {
  description = "Subnet Address Prefix"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID"
  type        = string
}

variable "sku" {
  description = "SKU of MySQL Server"
  type        = string
}

variable "db_version" {
  description = "Version of MySQL Server"
  type        = string
}

variable "db_name" {
  description = "Database Name"
  type        = string
}

variable "admin_username" {
  description = "Username for MySQL Server"
  type        = string
}

variable "admin_password" {
  description = "Password for MySQL Server"
  type        = string
  sensitive   = true
}

variable "geo_redundant_backup_enabled" {
  description = "Enable Geo-redundant Backup"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Backup Retention Days"
  type        = number
  default     = 7
}

variable "storage_size_gb" {
  description = "Storage Size (GB)"
  type        = number
  default     = 20
}

variable "storage_auto_grow_enabled" {
  description = "Enable Storage Auto Grow"
  type        = bool
  default     = false
}

variable "charset" {
  description = "Charset of Database"
  type        = string
  default     = "utf8mb4"
}

variable "collation" {
  description = "Collation of Database"
  type        = string
  default     = "utf8mb4_unicode_ci"
}
