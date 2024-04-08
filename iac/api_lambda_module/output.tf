
output "api_gateway_invoke_url" {
  value = aws_api_gateway_stage.api_prod_stage.invoke_url
}
