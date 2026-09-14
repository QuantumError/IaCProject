# Site 1 deployment (k8+helm)

locals {
  # Extensions treated as UTF-8 text (-> configmap "data"). Everything else
  # (images, fonts, etc.) goes through "binary_data" as base64, same reasoning
  # as the site2_content_types map in the webfront module: fileset() only
  # gives us paths, not types, so we derive it from the extension.
  text_extensions = ["html", "htm", "css", "js", "json", "svg", "txt", "xml"]

  site1_dir       = "${path.module}/${var.site1_source_dir}"
  site1_files     = fileset(local.site1_dir, "**")
  # ConfigMap data keys can't contain "/", so nested paths (e.g. css/style.css) need to be modified.
  site1_file_keys = { for f in local.site1_files : f => replace(f, "/", "__") }

  site1_extension = { for f in local.site1_files :
    f => lower(element(split(".", f), length(split(".", f)) - 1))
  }
}

resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

resource "kubernetes_config_map" "site1" {
  metadata {
    name      = "${var.site1_name}-files"
    namespace = var.namespace
  }

  data = {
    for f in local.site1_files : local.site1_file_keys[f] => file("${local.site1_dir}/${f}")
    if contains(local.text_extensions, local.site1_extension[f])
  }

  binary_data = {
    for f in local.site1_files : local.site1_file_keys[f] => filebase64("${local.site1_dir}/${f}")
    if !contains(local.text_extensions, local.site1_extension[f])
  }

  depends_on = [kubernetes_namespace.this]
}

resource "helm_release" "site1" {
  name      = var.site1_name
  namespace = var.namespace
  chart     = "${path.module}/chart"

  values = [
    yamlencode({
      image         = var.nginx_image
      replicaCount  = var.replica_count
      configMapName = kubernetes_config_map.site1.metadata[0].name
      service = {
        nodePort = var.site1_node_port
      }
      files = [for f in local.site1_files : { key = local.site1_file_keys[f], path = f }]
    })
  ]

  depends_on = [kubernetes_config_map.site1, kubernetes_namespace.this]
}
