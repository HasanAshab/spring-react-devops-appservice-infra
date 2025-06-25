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

variable "sku_tier" {
  description = "SKU Tier and Name"
  type        = string
}

variable "capacity" {
  description = "Capacity of SKU"
  type        = number
}

variable "backend_cookie_based_affinity" {
  description = "Cookie Based Affinity"
  type        = string
  default     = "Disabled"
}

variable "backend_path" {
  description = "Backend Path"
  type        = string
  default     = "/"
}

variable "backend_port" {
  description = "Backend Port"
  type        = number
  default     = 80
}

variable "backend_protocol" {
  description = "Protocol"
  type        = string
  default     = "Http"
}

variable "backend_request_timeout" {
  description = "Request Timeout"
  type        = number
  default     = 60
}

variable "port" {
  description = "Frontend Port"
  type        = number
}
