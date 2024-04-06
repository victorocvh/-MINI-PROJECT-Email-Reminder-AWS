
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

resource "aws_lambda_function" "email_reminder" {
    name        = "email_reminder_lambda"
    runtime     = "python3.9"
    role        = aws_iam_role.lambda_role.arn
    filename    = 
}