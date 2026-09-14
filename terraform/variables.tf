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

