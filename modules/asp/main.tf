module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming.git?ref=75d5afa" # v0.4.2
  suffix = concat(var.naming_suffix)
}

module "asp" {
  source                 = "git::https://github.com/Azure/terraform-azurerm-avm-res-web-serverfarm.git?ref=8ca49e2" # v0.7.0
  enable_telemetry       = var.enable_telemetry
  name                   = module.naming.app_service_plan.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  os_type                = var.os_type
  sku_name               = var.sku
  worker_count           = var.worker_count
  zone_balancing_enabled = var.enable_zone_balancing
}

resource "azurerm_monitor_autoscale_setting" "asp" {
  count               = var.autoscale_settings != null && var.autoscale_settings.enabled ? 1 : 0
  name                = module.naming.monitor_autoscale_setting.name
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = module.asp.resource_id

  profile {
    name = "default"

    capacity {
      default = coalesce(var.autoscale_settings["default_capacity"], var.worker_count)
      minimum = var.autoscale_settings.minimum_capacity
      maximum = var.autoscale_settings.maximum_capacity
    }

    dynamic "rule" {
      for_each = var.autoscale_settings.rules
      content {
        metric_trigger {
          metric_name        = rule.value.metric_trigger.metric_name
          metric_resource_id = module.asp.resource_id
          time_grain         = rule.value.metric_trigger.time_grain
          statistic          = rule.value.metric_trigger.statistic
          time_window        = rule.value.metric_trigger.time_window
          time_aggregation   = rule.value.metric_trigger.time_aggregation
          operator           = rule.value.metric_trigger.operator
          threshold          = rule.value.metric_trigger.threshold
        }

        scale_action {
          direction = rule.value.scale_action.direction
          type      = rule.value.scale_action.type
          value     = rule.value.scale_action.value
          cooldown  = rule.value.scale_action.cooldown
        }
      }
    }
  }
}
