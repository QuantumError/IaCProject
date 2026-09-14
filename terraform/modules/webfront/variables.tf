
variable "bucket_name" {
  description = "S3 bucket that will host the static website"
  type        = string
  default     = "my-sample-website"
}

variable "site2_bucket_name" {
  description = "S3 bucket that will host the second, multi-file static site (uploaded via fileset())"
  type        = string
  default     = "my-sample-website-2"
}