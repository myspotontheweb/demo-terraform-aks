provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "scoil-mark-1" {
  name     = "scoil-mark-1-resources"
  location = "West Europe"
}

resource "azurerm_container_registry" "scoil-mark-1" {
  name                = "scoilmarkdev"
  resource_group_name = azurerm_resource_group.scoil-mark-1.name
  location            = azurerm_resource_group.scoil-mark-1.location
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "scoil-mark-1" {
  name                = "scoil-mark-1-aks1"
  location            = azurerm_resource_group.scoil-mark-1.location
  resource_group_name = azurerm_resource_group.scoil-mark-1.name
  dns_prefix          = "scoilmark"
  kubernetes_version  = "1.23.8"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }

}

resource "azurerm_role_assignment" "scoil-mark-1" {
  scope                            = azurerm_container_registry.scoil-mark-1.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.scoil-mark-1.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

