resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "petcuddleotron-95dxas65x92sad9"
}

resource "aws_s3_bucket_policy" "allow_external_access" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "PublicRead",
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.frontend_bucket.arn}/*",
      },
    ],
  })
}

resource "aws_s3_bucket_website_configuration" "frontend_static" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }


}

locals {
  mime_types = {
    ".html" = "text/html"
    ".css" = "text/css"
    ".js" = "application/javascript"
    ".ico" = "image/vnd.microsoft.icon"
    ".jpeg" = "image/jpeg"
    ".png" = "image/png"
    ".svg" = "image/svg+xml"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_bucket_public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "files" {
  for_each = fileset("${path.module}/serverless_frontend/", "*")
  bucket   = aws_s3_bucket.frontend_bucket.bucket
  key      = each.value
  source   = "${path.module}/serverless_frontend/${each.value}"
  content_type = lookup(local.mime_types, lower(split(".", basename(each.value))[length(split(".", basename(each.value))) - 1]), "text/html")
  etag     = filebase64sha256("${path.module}/serverless_frontend/${each.value}")

  depends_on = [aws_s3_bucket.frontend_bucket]
}
