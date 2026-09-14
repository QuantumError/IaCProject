
output "grafana_url" {
  value = "http://localhost:3000"
}

output "prometheus_url" {
  value = "http://localhost:9090"
}

output "extra_buckets" {
  description = "Names of the additional provisioned buckets"
  value       = { for k, b in aws_s3_bucket.extra : k => b.id }
}