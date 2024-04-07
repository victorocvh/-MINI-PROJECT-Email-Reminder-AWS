
# Ele módulo api_lambda precisa receber o arn da state machine a ser executada.
variable "state_machine_arn" {
    type    = string
}

variable "email_reminder_lambda_arn" {
    type    = string
}
