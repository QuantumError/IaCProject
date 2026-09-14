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
