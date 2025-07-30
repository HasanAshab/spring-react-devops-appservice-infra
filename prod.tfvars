primary_location   = "centralus"
secondary_location = "eastus"
enable_telemetry   = true

# asp
asp_sku                        = "S1"
asp_worker_count               = 2
asp_zone_balancing_enabled     = true
asp_autoscaling_enabled        = true
asp_autoscale_default_capacity = 2
asp_autoscale_minimum_capacity = 2
asp_autoscale_maximum_capacity = 5

# database
database_sku                          = "B_Standard_B1ms"
database_version                      = "8.0.21"
database_name                         = "db"
database_admin_username               = "admin4321"
database_backup_retention_days        = 7
database_geo_redundant_backup_enabled = true
database_ha_enabled                   = true
database_storage_auto_grow_enabled    = true
database_storage_io_scaling_enabled   = true

# backend
backend_enable_application_insights  = true
backend_enable_blue_green_deployment = true
backend_docker_registry_url          = "https://ghcr.io/hasanashab"
backend_docker_image_name            = "spring-react-devops-appservice-backend"

# frontend
frontend_enable_application_insights  = true
frontend_enable_blue_green_deployment = true
frontend_docker_registry_url          = "https://ghcr.io/hasanashab"
frontend_docker_image_name            = "spring-react-devops-appservice-frontend"

# front door
frontdoor_sku = "Standard_AzureFrontDoor"
