terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "azurerm" {
  features {}
}
