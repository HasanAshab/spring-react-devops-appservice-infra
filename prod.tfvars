location = "westeurope"

# app gateway
appgw_sku  = "Standard_v2"
appgw_port = 80

# web
web_sku                 = "B1"
web_worker_count        = 2
web_docker_registry_url = "https://ghcr.io/hasanashab"
web_docker_image_name   = "spring-react-devops-appservice-frontend"

# app
app_sku                 = "B1"
app_worker_count        = 2
app_docker_registry_url = "https://ghcr.io/hasanashab"
app_docker_image_name   = "spring-react-devops-backend"
