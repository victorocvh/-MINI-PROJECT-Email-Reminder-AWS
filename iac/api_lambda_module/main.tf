terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.44.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.1.0"  # Escolha a versão desejada
    }
  }
}

data "aws_iam_role" "api_lambda_role" {
  name = "Lambda_SES_Role"
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
    role             = data.aws_iam_role.api_lambda_role.arn 
    runtime          = "python3.11"
    source_code_hash = data.archive_file.api_lambda_file.output_base64sha256
    architectures    = ["x86_64"]

    environment {
      variables = {
        state_machine_arn = var.state_machine_arn
      }
    }
}



# Criando recurso nulo, somente para garantir que esse módulo seja criado depois do módulo
# email reminder
resource "null_resource" "dependency" {
  depends_on = [
    var.email_reminder_lambda_arn
  ]
}
