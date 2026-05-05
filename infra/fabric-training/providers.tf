terraform {
  required_version = "~> 1.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16"
    }
    fabric = {
      source  = "microsoft/fabric"
      version = "~> 1.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }
}

# Comment this out if you want to run locally
terraform {
  backend "azurerm" {}
}

provider "fabric" {
  preview = true
}

provider "azurerm" {
  features {}
}

provider "azuread" {
  use_oidc = true
}
