terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.44.0"
    }
  }
}

resource "aws_iam_role" "api_lambda_role" {
    name        =  "API_Lambda_Role"  # Nome da role IAM
    assume_role_policy = jsonencode({  # Política de confiança da role
        "Version"   : "2012-10-17",
        "Statement" : [{
            "Effect"    : "Allow",
            "Principal" : {
                "Service" : "lambda.amazonaws.com"
            },
            "Action"    : "sts:AssumeRole"
        }]
    })

    # Anexando uma política inline à role que concede permissões específicas para o Lambda enviar e-mails usando SES
    inline_policy {
        name   = "Lambda_SES_Policy"
        policy = file("${path.module}/policies/ApiLambdaPolicy.json")  # Arquivo JSON contendo a política
    }
}

data "archive_file" "api_lambda_file" {
    type            = "zip"
    source_file     = "${path.module}/code/lambda_fn.py"
    output_path     = "${path.module}/code/lambda.zip"
}


resource "aws_lambda_function" "api_lambda" {

    filename         = "${path.module}/code/lambda.zip"
    function_name    = "api_lambda"
    handler          = "lambda_handler"
    role             = aws_iam_role.api_lambda_role.arn 
    runtime          = "python3.11"
    source_code_hash = data.archive_file.api_lambda_file.output_base64sha256
    architectures    = ["x86_64"]

    environment {
      variables = {
        state_machine_arn = var.state_machine_arn
      }
    }
}

resource "aws_api_gateway_rest_api" "api_rest" {
  name  = "petcuddleotron"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "api_rest_resource" {
    rest_api_id           = aws_api_gateway_rest_api.api_rest.id 
    parent_id             = aws_api_gateway_rest_api.api_rest.root_resource_id 
    path_part             = "petcuddleotron"
}

resource "aws_api_gateway_method" "post_api_rest_method" {
    rest_api_id   = aws_api_gateway_rest_api.api_rest.id
    resource_id   = aws_api_gateway_resource.api_rest_resource.id
    http_method   = "POST"
    authorization = "NONE"

}

resource "aws_api_gateway_integration" "post_api_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_rest.id 
  resource_id             = aws_api_gateway_resource.api_rest_resource.id 
  http_method             = aws_api_gateway_method.post_api_rest_method.http_method 
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_lambda.invoke_arn 
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id     = aws_api_gateway_rest_api.api_rest.id 

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api_rest.body))

  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_prod_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id 
  rest_api_id   = aws_api_gateway_rest_api.api_rest.id 
  stage_name    = "prod"
}


