location = "centralus"

# mysql
mysql_sku            = "B_Standard_B1ms"
mysql_version        = "8.0.21"
mysql_admin_username = "hasan"
mysql_admin_password = "averysecurepassword.123"
mysql_db_name        = "db1"

# app
app_sku                 = "B1"
app_worker_count        = 2
app_docker_registry_url = "https://ghcr.io/hasanashab"
app_docker_image_name   = "spring-react-devops-appservice-backend"

# web
web_sku                 = "B1"
web_worker_count        = 2
web_docker_registry_url = "https://ghcr.io/hasanashab"
web_docker_image_name   = "spring-react-devops-appservice-frontend"

