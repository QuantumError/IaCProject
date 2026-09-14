# Site 2 deployment (k8+helm)

locals {
  site2_dir       = "${path.module}/${var.site2_source_dir}"
  site2_files     = fileset(local.site2_dir, "**")
  site2_file_keys = { for f in local.site2_files : f => replace(f, "/", "__") }

  site2_extension = { for f in local.site2_files :
    f => lower(element(split(".", f), length(split(".", f)) - 1))
  }
}

resource "kubernetes_config_map" "site2" {
  metadata {
    name      = "${var.site2_name}-files"
    namespace = var.namespace
  }

  data = {
    for f in local.site2_files : local.site2_file_keys[f] => file("${local.site2_dir}/${f}")
    if contains(local.text_extensions, local.site2_extension[f])
  }

  binary_data = {
    for f in local.site2_files : local.site2_file_keys[f] => filebase64("${local.site2_dir}/${f}")
    if !contains(local.text_extensions, local.site2_extension[f])
  }

  depends_on = [kubernetes_namespace.this]
}

resource "helm_release" "site2" {
  name      = var.site2_name
  namespace = var.namespace
  chart     = "${path.module}/chart"

  values = [
    yamlencode({
      image         = var.nginx_image
      replicaCount  = var.replica_count
      configMapName = kubernetes_config_map.site2.metadata[0].name
      service = {
        nodePort = var.site2_node_port
      }
      files = [for f in local.site2_files : { key = local.site2_file_keys[f], path = f }]
    })
  ]

  depends_on = [kubernetes_config_map.site2, kubernetes_namespace.this]
}
