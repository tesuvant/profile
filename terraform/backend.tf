terraform {
  required_version = ">= 1.12.0"

  backend "azurerm" {
    resource_group_name  = "profile"
    storage_account_name = "827be54aprofile"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}