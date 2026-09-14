output "site1_node_port_url" {
  description = "URL for site 1 via NodePort. Replace <node-ip> with a real cluster node IP (`kubectl get nodes -o wide`), or 'localhost' for kind clusters with the port mapped, or `minikube ip` for minikube."
  value       = "http://<node-ip>:${var.site1_node_port}"
}

output "site2_node_port_url" {
  description = "URL for site 2 via NodePort. Replace <node-ip> as above."
  value       = "http://<node-ip>:${var.site2_node_port}"
}

output "namespace" {
  value = var.namespace
}

output "site1_files_uploaded" {
  description = "Every file key baked into site1's ConfigMap, for sanity-checking fileset() picked everything up"
  value       = [for f in local.site1_files : f]
}

output "site2_files_uploaded" {
  description = "Every file key baked into site2's ConfigMap, for sanity-checking fileset() picked everything up"
  value       = [for f in local.site2_files : f]
}
