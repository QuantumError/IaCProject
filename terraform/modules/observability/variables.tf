
variable "additional_buckets" {
  description = "Extra buckets to provision, keyed by suffix (appended to bucket_name), with a human-readable purpose as the value"
  type        = map(string)
  default = {
    assets  = "Static assets storage"
    logs    = "Deployment and access logs"
    backups = "Backup archives"
  }
}

variable "deployer_allowed_cidrs" {
  description = <<-EOT
    CIDR ranges the site-deployer credentials are allowed to call S3 from
    (enforced via an aws:SourceIp condition on the deployer IAM policy).
    Defaults to 0.0.0.0/0 (unrestricted) so the demo keeps working out of
    the box — in a real environment, set this to your CI runner's egress
    CIDR(s) so a leaked deployer key can't be used from anywhere else.
  EOT
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "bucket_name" {
  type = string
}