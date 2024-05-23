provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "retail-haven-rg-${random_integer.id.result}"
  location = "uksouth"
}

resource "random_integer" "id" {
  min = 1000
  max = 9999
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${azurerm_resource_group.rg.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "dns-label-${azurerm_resource_group.rg.name}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "null_resource" "get_kubectl_credentials" {
  provisioner "local-exec" {
    command     = <<-EOT
      az aks get-credentials -g ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing
      kubectl get nodes
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}