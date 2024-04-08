# Definição da role IAM que permite que as funções Lambda assumam essa role
resource "aws_iam_role" "lambda_role" {
    name        =  "Lambda_SES_Role"  # Nome da role IAM
    description =  "Essa role pode ser usada por lambdas para enviar emails SES."  # Descrição da role
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
        policy = file("${path.module}/policies/LambdaRole.json")  # Arquivo JSON contendo a política
    }
}

# Criação de um arquivo ZIP contendo o código do Lambda
data "archive_file" "lambda" {
    type        = "zip"
    source_file = "${path.module}/code/lambda_fn.py"  # Arquivo de código Python do Lambda
    output_path = "${path.module}/code/lambda.zip"  # Caminho para o arquivo ZIP de saída
}

# Definição da função Lambda
resource "aws_lambda_function" "email_reminder" {
    function_name      = "email_reminder_lambda"  # Nome da função Lambda
    filename           = "${path.module}/code/lambda.zip"  # Arquivo ZIP contendo o código do Lambda
    runtime            = "python3.11"  # Tempo de execução do Lambda
    role               = aws_iam_role.lambda_role.arn  # ARN da role IAM que permite que o Lambda assuma
    handler            = "lambda_fn.lambda_handler"  # Função de manipulador Lambda
    architectures      = ["x86_64"]  # Arquitetura da função Lambda
    source_code_hash   = data.archive_file.lambda.output_base64sha256  # Hash do código-fonte
}
