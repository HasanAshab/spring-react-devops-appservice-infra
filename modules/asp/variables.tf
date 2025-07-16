variable "naming_suffix" {
  description = "Extra Naming Suffix (be-*)"
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

variable "os_type" {
  description = "OS Type"
  type        = string
}

variable "sku" {
  description = "SKU of Service Plan"
  type        = string
}

variable "worker_count" {
  description = "Number of Workers"
  type        = number
}

variable "enable_zone_balancing" {
  description = "Enable Zone Balancing"
  type        = bool
  default     = null
}

variable "autoscale_settings" {
  description = "Autoscale Settings for Service Plan"

  type = object({
    enabled          = bool
    minimum_capacity = optional(number)
    maximum_capacity = optional(number)
    default_capacity = optional(number)
    rules = optional(list(object({
      metric_trigger = object({
        metric_name      = string
        time_grain       = string
        statistic        = string
        time_window      = string
        time_aggregation = string
        operator         = string
        threshold        = number
      })
      scale_action = object({
        direction = string
        type      = string
        value     = string
        cooldown  = string
      })
    })))
  })

  default = {
    enabled = false
  }

  validation {
    condition = (
      !var.autoscale_settings.enabled ||
      (
        var.autoscale_settings.minimum_capacity != null &&
        var.autoscale_settings.maximum_capacity != null &&
        var.autoscale_settings.rules != null &&
        length(var.autoscale_settings.rules) > 0
      )
    )
    error_message = "If autoscale is enabled, minimum_capacity, maximum_capacity, and rules must be defined and non-empty."
  }
}
