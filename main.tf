provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "scoil-mark-1"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr" {
  name                = "scoilmarkdev"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "scoil-mark-1-aks1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "scoilmark"
  kubernetes_version  = "1.23.8"

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    enable_auto_scaling = true
    min_count = 1
    max_count = 5
  }
  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = "Development"
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

