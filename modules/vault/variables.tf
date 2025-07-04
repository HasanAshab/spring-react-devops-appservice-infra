variable "name" {
  description = "Name of Private DNS Zone"
  type        = string
}

variable "location" {
  description = "Location of all resources"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "sku" {
  description = "SKU of Key Vault"
  type        = string
}

variable "soft_delete_retention_days" {
  description = "Soft Delete Retention Days"
  type        = number
  nullable    = true
  default     = null
}

variable "secrets" {
  description = "Secret Details"
  type = map(object({
    name    = string
    version = string
  }))
}

variable "secrets_value" {
  description = "Secret Values"
  type        = map(string)
  sensitive   = true
  ephemeral   = true
}
