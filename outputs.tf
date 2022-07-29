resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.scoil-mark-1]
  filename     = "kubeconfig"
  content      = azurerm_kubernetes_cluster.scoil-mark-1.kube_config_raw
}
