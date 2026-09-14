
# One aws_s3_bucket per entry in var.additional_buckets, e.g.
# my-sample-website-assets, my-sample-website-logs, my-sample-website-backups.
resource "aws_s3_bucket" "extra" {
  for_each = var.additional_buckets

  bucket = "${var.bucket_name}-${each.key}"
}

# Manifest object to add content to additional buckets.
resource "aws_s3_object" "manifest" {
  for_each = var.additional_buckets

  bucket       = aws_s3_bucket.extra[each.key].id
  key          = "manifest.json"
  content_type = "application/json"
  content = jsonencode({
    bucket      = aws_s3_bucket.extra[each.key].id
    purpose     = each.value
    provisioned = timestamp()
  })

  # timestamp() changes every apply; ignore so this doesn't force a
  # re-upload every single run.
  lifecycle {
    ignore_changes = [content]
  }
}

# Local provisioning step per extra bucket: writes an entry to a shared log file on create, and another on destroy.
resource "null_resource" "provision_log" {
  for_each = var.additional_buckets

  triggers = {
    bucket = aws_s3_bucket.extra[each.key].id
  }

  provisioner "local-exec" {
  command = "mkdir -p \"${path.module}/../logs\" && echo \"$(date -u +%Y-%m-%dT%H:%M:%SZ) CREATE  bucket=${var.bucket_name} purpose=${each.value}\" >> \"${path.module}/../logs/provision.log\""
}

  provisioner "local-exec" {
    when    = destroy
    command = "echo \"$(date -u +%Y-%m-%dT%H:%M:%SZ) DESTROY bucket=${self.triggers.bucket}\" >> ${path.module}/../logs/provision.log"
  }

  depends_on = [aws_s3_bucket.extra]
}