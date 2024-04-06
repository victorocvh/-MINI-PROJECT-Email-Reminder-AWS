
resource "aws_iam_role" "lambda_role" {
    name               =  "Lambda_SES_Role"
    description        =  "Essa role pode ser usada por lambdas para enviar emails SES."
    assume_role_policy = jsonencode({
        "Version"   : "2012-10-17",
        "Statement" : [{
        "Effect"    : "Allow",
        "Principal" : {
            "Service" : "lambda.amazonaws.com"
        },
        "Action"    : "sts:AssumeRole"
        }]
    })

    inline_policy {
        name = "Lambda_SES_Policy"
        policy = file("${path.module}/policies/LambdaRole.json")
    }
}

data "archive_file" "lambda" {
    type        = "zip"
    source_file = "${path.module}/code/lambda_fn.py"
    output_path = "${path.module}/code/lambda.zip"
}

resource "aws_lambda_function" "email_reminder" {

    function_name       = "email_reminder_lambda"
    filename            = "${path.module}/code/lambda.zip"
    runtime             = "python3.11"
    role                = aws_iam_role.lambda_role.arn
    handler             = "lambda_handler"
    architectures       = ["x86_64"]
    source_code_hash    = data.archive_file.lambda.output_base64sha256
}

