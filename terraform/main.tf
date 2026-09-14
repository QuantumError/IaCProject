# Root
module "webfront" {
  source     = "./modules/webfront"
  bucket_name = var.bucket_name
  site2_bucket_name = var.site2_bucket_name
}

module "observability" {
  source     = "./modules/observability"
  bucket_name = var.bucket_name
  additional_buckets = {
    "logs" = "Bucket for storing logs"
  }
}

module "security" {
  source     = "./modules/security"
  bucket_name = var.bucket_name
  site2_bucket_name = var.site2_bucket_name
  additional_buckets = {
    "secure" = "Bucket for storing secure files"
  }
}

module "deployment" {
  source = "./modules/deployment"

  namespace        = "webfront"
  create_namespace = true

  site1_name       = "site1"
  site1_source_dir = "../website"
  site1_node_port  = 30080

  site2_name       = "site2"
  site2_source_dir = "../website2"
  site2_node_port  = 30081

  nginx_image   = "nginx:1.27-alpine"
  replica_count = 1
}