variable "extra_naming_suffix" {
  description = "Extra Naming Suffix (be-*)"
  type        = list(string)
  default     = []
}

variable "enable_telemetry" {
  description = "Enable Telemetry for this module"
  type        = bool
  default     = true
}

variable "enable_application_insights" {
  description = "Enable Application Insights"
  type        = bool
  default     = true
}

variable "enable_blue_green_deployment" {
  description = "If enabled, staging slot will be created"
  type        = bool
  default     = false
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

variable "asp_id" {
  description = "App Service Plan ID"
  type        = string
}

variable "os_type" {
  description = "OS Type"
  type        = string
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

variable "health_check_path" {
  description = "Health Check Path"
  type        = string
  default     = "/"
}

variable "health_check_eviction_time_in_min" {
  description = "Health Check Eviction Time (in minutes)"
  type        = number
  default     = 10
}

variable "port" {
  description = "Exposed Port of the container"
  type        = number
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

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = null
}
