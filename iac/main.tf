terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.44.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "ses" {
  source          = "./ses_module"
  sender_email    = "@EMAIL_SENDER"
  receiver_email  = "@EMAIL_RECEIVER"
}

module "email_reminder" {
  source = "./email_reminder_lambda_module"
}

module "state_machine" {
  source                = "./state_machine_module"
  lambda_arn_to_invoke  = "${module.email_reminder.email_reminder_lambda_arn}"
}

module "api_lambda" {
  source            = "./api_lambda_module"
  state_machine_arn = "${module.state_machine.state_machine_arn}"
}

module "frontend_module" {
  source      = "./frontend_module"
}