output "websites" {
  description = "Direct object URLs for the deployed pages (MinIO serves objects directly)"
  value       = {
    site1 = "http://localhost:9000/${var.bucket_name}/index.html"
    site2 = "http://localhost:9000/${var.site2_bucket_name}/index.html"
  }
}