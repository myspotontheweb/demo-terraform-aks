provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.resource_group_location
}

resource "azurerm_container_registry" "acr" {
  name                = var.registry_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.name
  kubernetes_version  = var.kubernetes_version

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
    Environment = var.environment_tag
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

