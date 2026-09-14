
variable "bucket_name" {
  type = string
}

variable "site2_bucket_name" {
  type = string
}

variable "additional_buckets" {
  description = "Map of additional buckets to create, with the key being the bucket name suffix and the value being a description"
  type        = map(string)
  default     = {}
}

variable "deployer_allowed_cidrs" {
  description = <<-EOT
    CIDR ranges the site-deployer credentials are allowed to call S3 from
    (enforced via an aws:SourceIp condition on the deployer IAM policy).
    EOT
    type        = list(string)
    default     = ["0.0.0.0/0"]
}

