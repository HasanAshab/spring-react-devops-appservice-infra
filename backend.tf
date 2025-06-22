terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatehasan"
    container_name       = "tfstate"
    key                  = "three-tier-app.terraform.tfstate"
  }
}