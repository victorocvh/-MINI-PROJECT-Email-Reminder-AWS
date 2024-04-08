
output "api_gateway_output" {
    value = module.api_lambda.api_gateway_invoke_url
}