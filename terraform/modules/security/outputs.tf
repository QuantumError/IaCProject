output "site_reader_access_key" {
  description = "Access key for the read-only IAM user"
  value       = minio_iam_user.site_reader.name
}

output "site_reader_secret_key" {
  description = "Secret key for the read-only IAM user"
  value       = minio_iam_user.site_reader.secret
  sensitive   = true
}

output "site_deployer_access_key" {
  description = "Access key for the read-write IAM user"
  value       = minio_iam_user.site_deployer.name
}

output "site_deployer_secret_key" {
  description = "Secret key for the read-write IAM user"
  value       = minio_iam_user.site_deployer.secret
  sensitive   = true
}

output "log_writer_access_key" {
  description = "Access key for the write-only logs IAM user (empty if no 'logs' entry in additional_buckets)"
  value       = try(minio_iam_user.log_writer[0].name, null)
}

output "log_writer_secret_key" {
  description = "Secret key for the write-only logs IAM user"
  value       = try(minio_iam_user.log_writer[0].secret, null)
  sensitive   = true
}

output "backup_writer_access_key" {
  description = "Access key for the write-only, delete-denied backups IAM user (empty if no 'backups' entry in additional_buckets)"
  value       = try(minio_iam_user.backup_writer[0].name, null)
}

output "backup_writer_secret_key" {
  description = "Secret key for the write-only, delete-denied backups IAM user"
  value       = try(minio_iam_user.backup_writer[0].secret, null)
  sensitive   = true
}