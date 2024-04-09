output "static_website_link" {
  value = aws_s3_bucket_website_configuration.frontend_static.website_endpoint 
}