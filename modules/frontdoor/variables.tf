variable "profile_name" {
  description = "Profile Name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "sku" {
  description = "SKU of Service Plan"
  type        = string
}

variable "routes" {
  description = "Map of route definitions"
  type = map(object({
    patterns_to_match      = list(string)
    supported_protocols    = optional(list(string), ["Http", "Https"])
    forwarding_protocol    = optional(string, "HttpsOnly")
    link_to_default_domain = optional(bool, true)
    https_redirect_enabled = optional(bool, true)
    origin_group = optional(object({
      session_affinity_enabled                                  = optional(bool, true)
      restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number, 10)
      load_balancing = optional(object({
        additional_latency_in_milliseconds = optional(number, 0)
        sample_size                        = optional(number, 16)
        successful_samples_required        = optional(number, 3)
      }))
      health_probe = optional(object({
        interval_in_seconds = optional(number, 30)
        path                = optional(string, "/")
        protocol            = optional(string, "Https")
        request_type        = optional(string, "HEAD")
      }))
    }))
    origins = list(object({
      host_name                      = string
      priority                       = number
      weight                         = optional(number, 100)
      certificate_name_check_enabled = optional(bool, true)
    }))
  }))
}
