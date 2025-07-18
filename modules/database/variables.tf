variable "extra_naming_suffix" {
  description = "Extra Naming Suffix (db-*)"
  type        = list(string)
  default     = []
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

variable "vnet_id" {
  description = "Virtual Network ID"
  type        = string
}

variable "vnet_name" {
  description = "Virtual Network Name"
  type        = string
}

variable "snet_address_prefix" {
  description = "Subnet Address Prefix of Private Endpoint"
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

variable "admin_password_wo" {
  description = "Password for MySQL Server (Write Only)"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "admin_password_wo_version" {
  description = "Write Only Password Version"
  type        = number
}

variable "enable_geo_redundant_backup" {
  description = "Enable Geo-Redundant Backup"
  type        = bool
}

variable "backup_retention_days" {
  description = "Backup Retention Days"
  type        = number
  default     = null
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

variable "storage_iops" {
  description = "Storage IOPS"
  type        = number
  nullable    = true
  default     = null
}

variable "storage_io_scaling_enabled" {
  description = "Enable Storage I/O Scaling"
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
