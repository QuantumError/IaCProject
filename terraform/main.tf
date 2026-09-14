# Root
module "webfront" {
  source     = "./modules/webfront"
  bucket_name = var.bucket_name
  site2_bucket_name = var.site2_bucket_name
}