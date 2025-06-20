terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatehasan"
    container_name       = "tfstate"
    key                  = "go-web-app.terraform.tfstate"
  }
}