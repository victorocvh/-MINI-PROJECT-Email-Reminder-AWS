resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "petcuddleotron-95dxas65x92sad9"
}

resource "aws_s3_bucket_policy" "allow_external_access" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicRead",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*",
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
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "ico"  = "image/vndmicrosofticon"
    "jpeg" = "image/jpeg"
    "png"  = "image/png"
    "svg"  = "image/svg+xml"
  }

}

resource "aws_s3_bucket_public_access_block" "frontend_bucket_public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "local_file" "serveless_js_temp" {
  filename = "${path.module}/serverless_frontend/serverless_temp.js"
  content = templatefile("${path.module}/serverless_frontend/serverless.js", {
    replace_endpoint = var.api_gateway_invoke_url
  })
}

resource "aws_s3_object" "files" {
  for_each = fileset("${path.module}/serverless_frontend/", "*")
  bucket   = aws_s3_bucket.frontend_bucket.bucket
  key      = each.value
  source   = each.value == "serverless.js" ? local_file.serveless_js_temp.filename : "${path.module}/serverless_frontend/${each.value}"

  content_type = lookup(local.mime_types, split(".", each.value)[1], "?? what")
  etag         = filebase64sha256("${path.module}/serverless_frontend/${each.value}")

  depends_on = [aws_s3_bucket.frontend_bucket]
}
