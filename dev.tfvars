location = "westeurope"

# app gateway
appgw_sku  = "Standard_v2"
appgw_port = 80

# web
web_sku             = "Standard_F2"
web_instances       = 2
web_image_offer     = "0001-com-ubuntu-server-jammy"
web_image_sku       = "22_04-lts"
web_public_key_path = "~/.ssh/hasan_rsa.pub"