locals {
  endpoint_name = "fd-endpoint"
  origins = merge([
    for route_name, route in var.routes : {
      for idx, origin in route.origins :
      "${route_name}-${idx}" => {
        route_name = route_name
        name       = "fd-origin-${route_name}-${idx}"
        host_name  = origin.host_name
        priority   = origin.priority
        weight     = origin.weight
        cert_check = origin.certificate_name_check_enabled
      }
    }
  ]...)
}
