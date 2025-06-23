location = "westeurope"

# app gateway
appgw_sku  = "Standard_v2"
appgw_port = 80

# vm scale-set
web_sku             = "Standard_F2"
web_instances       = 2
web_public_key_path = "~/.ssh/hasan_rsa.pub"