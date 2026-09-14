# ---------------------------------------------------------------------------
# IAM: features four users
#
#   - site_reader:   read-only across both site buckets
#   - site_deployer: read/write on the two site buckets + the assets bucket
#                    only, with explicit deny on logs/backups so a compromised deployer key
#                    can't be used to destroy logs/backups
#   - log_writer:    write-only on the logs bucket (a logging sidecar should
#                    never be able to read or delete what it wrote)
#   - backup_writer: write-only on the backups bucket, with an explicit deny
#                    on delete so a compromised backup credential can't be
#                    used to wipe backups
# ---------------------------------------------------------------------------



locals {
  site_buckets = [var.bucket_name, var.site2_bucket_name]
  has_assets_bucket  = contains(keys(var.additional_buckets), "assets")
  has_logs_bucket    = contains(keys(var.additional_buckets), "logs")
  has_backups_bucket = contains(keys(var.additional_buckets), "backups")

  assets_bucket  = local.has_assets_bucket ? "${var.bucket_name}-assets" : null
  logs_bucket    = local.has_logs_bucket ? "${var.bucket_name}-logs" : null
  backups_bucket = local.has_backups_bucket ? "${var.bucket_name}-backups" : null

  reader_bucket_arns = [for b in local.site_buckets : "arn:aws:s3:::${b}"]
  reader_object_arns = [for b in local.site_buckets : "arn:aws:s3:::${b}/*"]

  deployer_buckets     = concat(local.site_buckets, local.has_assets_bucket ? [local.assets_bucket] : [])
  deployer_bucket_arns = [for b in local.deployer_buckets : "arn:aws:s3:::${b}"]
  deployer_object_arns = [for b in local.deployer_buckets : "arn:aws:s3:::${b}/*"]

  # Buckets the deployer is explicitly denied from, regardless of any other
  # grant it might ever pick up (logs, backups).
  deployer_denied_bucket_arns = compact([
    local.has_logs_bucket ? "arn:aws:s3:::${local.logs_bucket}" : "",
    local.has_backups_bucket ? "arn:aws:s3:::${local.backups_bucket}" : "",
  ])
  deployer_denied_object_arns = compact([
    local.has_logs_bucket ? "arn:aws:s3:::${local.logs_bucket}/*" : "",
    local.has_backups_bucket ? "arn:aws:s3:::${local.backups_bucket}/*" : "",
  ])
}

resource "minio_iam_policy" "site_reader" {
  name = "site-reader-read-only"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListSiteBuckets"
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = local.reader_bucket_arns
      },
      {
        Sid      = "ReadSiteObjects"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = local.reader_object_arns
      }
    ]
  })
}

resource "minio_iam_policy" "site_deployer" {
  name = "site-deployer-read-write"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid      = "ListDeployBuckets"
          Effect   = "Allow"
          Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
          Resource = local.deployer_bucket_arns
          Condition = {
            IpAddress = { "aws:SourceIp" = var.deployer_allowed_cidrs }
          }
        },
        {
          Sid      = "ReadWriteDeployObjects"
          Effect   = "Allow"
          Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
          Resource = local.deployer_object_arns
          Condition = {
            IpAddress = { "aws:SourceIp" = var.deployer_allowed_cidrs }
          }
        }
      ],
      length(local.deployer_denied_bucket_arns) > 0 ? [
        {
          Sid      = "DenyLogsAndBackups"
          Effect   = "Deny"
          Action   = ["s3:*"]
          Resource = concat(local.deployer_denied_bucket_arns, local.deployer_denied_object_arns)
        }
      ] : []
    )
  })
}

resource "minio_iam_policy" "log_writer" {
  count = local.has_logs_bucket ? 1 : 0

  name = "log-writer-write-only"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "PutLogObjects"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = ["arn:aws:s3:::${local.logs_bucket}/*"]
      },
      {
        Sid      = "DenyReadDeleteLogs"
        Effect   = "Deny"
        Action   = ["s3:GetObject", "s3:DeleteObject", "s3:ListBucket"]
        Resource = ["arn:aws:s3:::${local.logs_bucket}", "arn:aws:s3:::${local.logs_bucket}/*"]
      }
    ]
  })
}

resource "minio_iam_policy" "backup_writer" {
  count = local.has_backups_bucket ? 1 : 0

  name = "backup-writer-append-only"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "PutBackupObjects"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = ["arn:aws:s3:::${local.backups_bucket}/*"]
      },
      {
        Sid      = "DenyDeleteBackups"
        Effect   = "Deny"
        Action   = ["s3:DeleteObject", "s3:DeleteBucket"]
        Resource = ["arn:aws:s3:::${local.backups_bucket}", "arn:aws:s3:::${local.backups_bucket}/*"]
      }
    ]
  })
}

resource "minio_iam_user" "site_reader" {
  name          = "site-reader"
  force_destroy = true
}

resource "minio_iam_user" "site_deployer" {
  name          = "site-deployer"
  force_destroy = true
}

resource "minio_iam_user" "log_writer" {
  count = local.has_logs_bucket ? 1 : 0

  name          = "log-writer"
  force_destroy = true
}

resource "minio_iam_user" "backup_writer" {
  count = local.has_backups_bucket ? 1 : 0

  name          = "backup-writer"
  force_destroy = true
}

resource "minio_iam_user_policy_attachment" "site_reader" {
  user_name   = minio_iam_user.site_reader.name
  policy_name = minio_iam_policy.site_reader.name
}

resource "minio_iam_user_policy_attachment" "site_deployer" {
  user_name   = minio_iam_user.site_deployer.name
  policy_name = minio_iam_policy.site_deployer.name
}

resource "minio_iam_user_policy_attachment" "log_writer" {
  count = local.has_logs_bucket ? 1 : 0

  user_name   = minio_iam_user.log_writer[0].name
  policy_name = minio_iam_policy.log_writer[0].name
}

resource "minio_iam_user_policy_attachment" "backup_writer" {
  count = local.has_backups_bucket ? 1 : 0

  user_name   = minio_iam_user.backup_writer[0].name
  policy_name = minio_iam_policy.backup_writer[0].name
}