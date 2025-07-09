variable "extra_naming_suffix" {
  description = "Extra Naming Suffix (be-*)"
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

variable "vnet_name" {
  description = "Virtual Network Name"
  type        = string
}

variable "snet_address_prefix" {
  description = "Subnet Address Prefix"
  type        = string
}


variable "sku" {
  description = "SKU of VM-Scale Set"
  type        = string
}

variable "worker_count" {
  description = "Number of Workers"
  type        = number
}

variable "docker_registry_url" {
  description = "Docker Registry URL"
  type        = string
}

variable "docker_image_name" {
  description = "Docker Image Name"
  type        = string
}

variable "docker_image_tag" {
  description = "Docker Image Tag"
  type        = string
  default     = "latest"
}

variable "port" {
  description = "Port"
  type        = string
}

variable "db_host" {
  description = "Database FQDN"
  type        = string
}

variable "db_name" {
  description = "Database Name"
  type        = string
}

variable "db_username" {
  description = "Database Username"
  type        = string
}

variable "db_password" {
  description = "Database Password"
  type        = string
  sensitive   = true
}
