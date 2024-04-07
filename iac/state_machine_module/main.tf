terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.44.0"
    }
  }
}


resource "aws_iam_role" "state_machine_role" {
    name                = "StateMachineRole"
    assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })

    inline_policy {
        name = "state_machine_permissions"
        policy = file("${path.module}/policies/StateMachinePolicy.json")
    }
}

resource "aws_cloudwatch_log_group" "log_group_for_sfn" {
    name = "/aws/states/reminder-workflow"
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
    name        = "reminder-workflow"
    role_arn    = aws_iam_role.state_machine_role.arn 

    # definition = file("${path.module}/code/state_machine_definition.json")
    definition = <<EOF
    {
    "Comment": "Pet Cuddle-o-Tron - using Lambda for email.",
    "StartAt": "Timer",
    "States": {
      "Timer": {
        "Type": "Wait",
        "SecondsPath": "$.waitSeconds",
        "Next": "Email"
      },
      "Email": {
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke",
        "Parameters": {
          "FunctionName": "${var.lambda_arn_to_invoke}",
          "Payload": {
            "Input.$": "$"
          }
        },
        "Next": "NextState"
      },
      "NextState": {
        "Type": "Pass",
        "End": true
      }
    }
  }
    EOF

    logging_configuration {
        level                   = "ALL"
        include_execution_data  = true
        log_destination        = "${aws_cloudwatch_log_group.log_group_for_sfn.arn}:*"
    }
}