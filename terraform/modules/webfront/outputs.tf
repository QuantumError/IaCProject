
output "website_url" {
  description = "Direct object URL for the deployed page (MinIO serves objects directly)"
  value       = "http://localhost:9000/${var.bucket_name}/index.html"
}

output "site2_website_url" {
  description = "Direct object URL for the second, multi-file site's index page"
  value       = "http://localhost:9000/${var.site2_bucket_name}/index.html"
}

output "minio_console" {
  value = "http://localhost:9001"
}

output "site2_uploaded_files" {
  description = "Every object key uploaded to the site2 bucket, for sanity-checking fileset() picked everything up"
  value       = [for f in aws_s3_object.site2_files : f.key]
}