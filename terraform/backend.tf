terraform {
  required_version = ">= 1.6"

  backend "s3" {
    bucket = "terraform-state"
    key    = "webapp/terraform.tfstate"
    region = "us-east-1"

    access_key = "minioadmin"
    secret_key = "minioadmin123"

    endpoints = {
      s3 = "http://minio:9000"
    }

    use_path_style               = true
    skip_credentials_validation  = true
    skip_metadata_api_check      = true
    skip_region_validation       = true
    skip_requesting_account_id   = true
  }
}