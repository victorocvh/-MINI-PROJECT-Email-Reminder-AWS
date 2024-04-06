terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.44.0"
    }
  }
}

provider "aws" {
}

module "ses" {
  source          = "./ses_module"
  sender_email    = "victor.ocv+sender@hotmail.com"
  receiver_email  = "victor.ocv+receiver@hotmail.com"
}

module "email_reminder" {
  source = "./email_reminder_lambda_module"
}