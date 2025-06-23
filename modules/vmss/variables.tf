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

variable "sn_address_prefix" {
  description = "Subnet Address Prefix"
  type        = string
}

variable "sku" {
  description = "SKU of VM-Scale Set"
  type        = string
}

variable "instances" {
  description = "Number of VM instances"
  type        = number
}

variable "admin_username" {
  description = "Admin Username"
  type        = string
}

variable "public_key_path" {
  description = "Public Key File Path of VMs"
  type        = string
}

variable "backend_address_pool_ids" {
  description = "Backend Address Pool IDs"
  type        = set(string)
}

variable "image_publisher" {
  description = "Publisher of the OS image"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Offer of the OS image"
  type        = string
}

variable "image_sku" {
  description = "SKU/Variant of the OS image"
  type        = string
}

variable "image_version" {
  description = "Version of the OS image"
  type        = string
  default     = "latest"
}

variable "custom_data" {
  description = "Custom Data (init file)"
  type        = string
}