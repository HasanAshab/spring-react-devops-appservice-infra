variable "extra_naming_suffix" {
  description = "Extra Naming Suffix (fe-*)"
  type        = list(string)
  default     = []
}

variable "enable_telemetry" {
  description = "Enable Telemetry for this module"
  type        = bool
  default     = true
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

variable "asp_id" {
  description = "App Service Plan ID"
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
