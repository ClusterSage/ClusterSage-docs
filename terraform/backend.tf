terraform {
  backend "azurerm" {
    resource_group_name  = "rg-clustersage-tfstate"
    storage_account_name = "stclustersagetfstate"
    container_name       = "tfstate"
    key                  = "clustersage.tfstate"
  }
}
