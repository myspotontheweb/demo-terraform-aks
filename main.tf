terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.15.1"
    }
  }
}

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
  principal_id                     = azurerm_kubernetes_cluster.scoil-mark-1.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.scoil-mark-1.id
  skip_service_principal_aad_check = true
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.scoil-mark-1.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.scoil-mark-1.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.scoil-mark-1.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.scoil-mark-1.kube_config.0.cluster_ca_certificate)
  }
}

resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  namespace        = "kube-addons"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.2.0"
  create_namespace = true
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  namespace        = "kube-addons"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.8.0"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }
}

resource "helm_release" "external-dns" {
  name             = "external-dns"
  namespace        = "kube-addons"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "external-dns"
  version          = "6.7.2"
  create_namespace = true
}
