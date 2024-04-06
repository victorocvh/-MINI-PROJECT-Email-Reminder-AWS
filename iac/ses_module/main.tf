terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.44.0"
    }
  }
}


resource "aws_ses_email_identity" "sender_email" {
  email = var.sender_email
}

resource "aws_ses_email_identity" "receiver_email" {
  email = var.receiver_email
}


