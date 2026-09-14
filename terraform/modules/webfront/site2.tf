# Site2 uses Terraform fileset() to deploy dynamic website

locals {
  site2_content_types = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    json = "application/json"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    svg  = "image/svg+xml"
    ico  = "image/x-icon"
  }
}

resource "aws_s3_bucket" "site2" {
  bucket = var.site2_bucket_name
}

resource "aws_s3_bucket_policy" "site2_public_read" {
  bucket = aws_s3_bucket.site2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "arn:aws:s3:::${var.site2_bucket_name}/*"
    }]
  })

  depends_on = [aws_s3_bucket.site2]
}

resource "aws_s3_object" "site2_files" {
  for_each = fileset("${path.module}/../website2", "**")

  bucket = aws_s3_bucket.site2.id
  key    = each.value
  source = "${path.module}/../website2/${each.value}"
  etag   = filemd5("${path.module}/../website2/${each.value}")
  
  content_type = lookup(
    local.site2_content_types,
    element(split(".", each.value), length(split(".", each.value)) - 1),
    "application/octet-stream"
  )

  depends_on = [aws_s3_bucket.site2]
}