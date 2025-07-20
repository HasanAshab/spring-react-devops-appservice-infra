
resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = local.profile_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = local.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
}



resource "azurerm_cdn_frontdoor_origin_group" "this" {
  for_each                                                  = var.routes
  name                                                      = "fd-origin-group-${each.key}"
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.this.id
  session_affinity_enabled                                  = each.value.origin_group.session_affinity_enabled
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = each.value.origin_group.restore_traffic_time_to_healed_or_new_endpoint_in_minutes

  load_balancing {
    additional_latency_in_milliseconds = each.value.origin_group.load_balancing.additional_latency_in_milliseconds
    sample_size                        = each.value.origin_group.load_balancing.sample_size
    successful_samples_required        = each.value.origin_group.load_balancing.successful_samples_required
  }

  health_probe {
    interval_in_seconds = each.value.origin_group.health_probe.interval_in_seconds
    path                = each.value.origin_group.health_probe.path
    protocol            = each.value.origin_group.health_probe.protocol
    request_type        = each.value.origin_group.health_probe.request_type
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each                       = local.origins
  name                           = each.value.name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this[each.value.route_name].id
  host_name                      = each.value.host_name
  origin_host_header             = each.value.host_name
  priority                       = each.value.priority
  weight                         = each.value.weight
  certificate_name_check_enabled = each.value.certificate_name_check_enabled
  enabled                        = true
  http_port                      = 80
  https_port                     = 443
}

resource "azurerm_cdn_frontdoor_route" "frontend" {
  for_each                      = var.routes
  name                          = "fd-route-${each.key}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[each.key].id
  cdn_frontdoor_origin_ids = [
    for idx in range(length(each.value.origins)) :
    azurerm_cdn_frontdoor_origin.this["${each.key}-${idx}"].id
  ]
  patterns_to_match      = each.value.patterns_to_match
  supported_protocols    = each.value.supported_protocols
  forwarding_protocol    = each.value.forwarding_protocol
  link_to_default_domain = each.value.link_to_default_domain
  https_redirect_enabled = each.value.https_redirect_enabled
}
