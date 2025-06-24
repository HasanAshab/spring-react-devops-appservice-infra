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

variable "sku" {
  description = "SKU of VM-Scale Set"
  type        = string
}

variable "worker_count" {
  description = "Number of Workers"
  type        = number
}

variable "app_settings" {
  description = "Application Settings"
  type        = map(string)
  default     = {}
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
  default = "latest"
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID"
  type        = string
}