provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks" {
  name     = "ecommerce-rg-${random_integer.random_id.result}"
  location = "uksouth"
}

resource "random_integer" "random_id" {
  min = 1000
  max = 9999
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "aks-${azurerm_resource_group.aks.name}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "dns-label-${azurerm_resource_group.aks.name}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

provider "helm" {
  kubernetes {
    config_path = "C:\\Users\\zulfi\\.kube\\config"
  }
}

resource "helm_release" "retail_therapy_app" {
  name    = "retail-therapy-app"
  chart   = "C:\\Users\\zulfi\\cloud\\kubernetes\\k8s-resume-challenge\\helm\\retail-therapy-app"
  version = "1.16.0"
}