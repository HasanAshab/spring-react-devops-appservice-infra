
resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = "fd-profile"
  resource_group_name = var.resource_group_name
  sku_name            = var.sku
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = "fd-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  name                                                      = "pool"
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.this.id
  session_affinity_enabled                                  = true
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }

  health_probe {
    interval_in_seconds = 30
    path                = "/"
    protocol            = "Https"
    request_type        = "GET"
  }
}


resource "azurerm_cdn_frontdoor_origin" "all" {
  for_each = var.origins
  name     = each.key
}

resource "azurerm_cdn_frontdoor_origin" "frontend" {
  for_each                       = module.frontend
  name                           = "frontend-${each.key}-pool"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this.id
  enabled                        = true
  host_name                      = each.value.resource_uri
  origin_host_header             = each.value.resource_uri
  http_port                      = 80
  https_port                     = 443
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_origin" "backend" {
  for_each                       = module.backend
  name                           = "backend-${each.key}-pool"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this.id
  enabled                        = true
  host_name                      = each.value.resource_uri
  origin_host_header             = each.value.resource_uri
  http_port                      = 80
  https_port                     = 443
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true
}


resource "azurerm_cdn_frontdoor_route" "frontend" {
  name                          = "route-frontend"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id
  cdn_frontdoor_origin_ids      = values(azurerm_cdn_frontdoor_origin.frontend)[*].id
  supported_protocols           = ["Http", "Https"]
  patterns_to_match             = ["/*"]
  forwarding_protocol           = "HttpsOnly"
  link_to_default_domain        = true
  https_redirect_enabled        = true
}

resource "azurerm_cdn_frontdoor_route" "backend" {
  name                          = "route-backend"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id
  cdn_frontdoor_origin_ids      = values(azurerm_cdn_frontdoor_origin.backend)[*].id
  supported_protocols           = ["Http", "Https"]
  patterns_to_match             = ["/api/*"]
  forwarding_protocol           = "HttpsOnly"
  link_to_default_domain        = true
  https_redirect_enabled        = true
}
