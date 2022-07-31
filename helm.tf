provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
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
  name              = "cert-manager"
  namespace         = "kube-addons"
  chart             = "./addons/cert-manager-umbrella"
  create_namespace  = true
  dependency_update = true

  set {
    name  = "cert-manager.installCRDs"
    value = true
  }
}

data "azurerm_dns_zone" "dns" {
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
}

data "azurerm_client_config" "current" {
}

resource "azurerm_role_assignment" "dns_update" {
  scope                            = data.azurerm_dns_zone.dns.id
  role_definition_name             = "DNS Zone Contributor"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

resource "helm_release" "external-dns" {
  name             = "external-dns"
  namespace        = "kube-addons"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "external-dns"
  version          = "6.7.2"
  create_namespace = true

  set {
    name  = "provider"
    value = "azure"
  }
  set {
    name  = "txtOwnerId"
    value = "scoil-mark-1"
  }
  set {
    name  = "policy"
    value = "sync"
  }
  set {
    name  = "azure.resourceGroup"
    value = data.azurerm_dns_zone.dns.resource_group_name
  }
  set {
    name  = "azure.tenantId"
    value = data.azurerm_client_config.current.tenant_id
  }
  set {
    name  = "azure.subscriptionId"
    value = data.azurerm_client_config.current.subscription_id
  }
  set {
    name  = "azure.useManagedIdentityExtension"
    value = true
  }
  set {
    name  = "azure.userAssignedIdentityID"
    value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
  }
}

