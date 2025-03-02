# environment variables
variable "region" {
  description = "region to create resources"
  type        = string
}

variable "project_name" {
  description = "project name"
  type        = string
}

variable "environment" {
  description = "environment"
  type        = string
}

# vpc variables
variable "vpc_cidr" {
  description = "vpc cidr block"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "public subnet az1 cidr block"
  type        = string
}

variable "public_subnet_az2_cidr" {
  description = "public subnet az2 cidr block"
  type        = string
}

variable "private_app_subnet_az1_cidr" {
  description = "private app subnet az1 cidr block"
  type        = string
}

variable "private_app_subnet_az2_cidr" {
  description = "private app subnet az2 cidr block"
  type        = string
}

variable "private_data_subnet_az1_cidr" {
  description = "private data subnet az1 cidr block"
  type        = string
}

variable "private_data_subnet_az2_cidr" {
  description = "private data subnet az2 cidr block"
  type        = string
}


variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  default     = "notification-queue"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  default     = "NotificationsTable"
}

variable "sns_topic_name" {
  description = "SNS topic name"
  default     = "sns_notifications"
}

variable "ses_topic_name" {
  description = "SES topic name"
  default     = "ses_notifications"
}

variable "default_email" {
  description = "SES default email"
  default     = "faitheffie25@gmail.com"
}

variable "aws_api_gateway_rest_api" {
  description = "API gateway name"
  default     = "aws_api_gateway_rest_api"
}

resource "aws_lambda_function" "metadata_logger" {
  function_name = "MetadataLoggerLambda"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.9"
  handler       = "index.lambda_handler"
  filename      = "lambda.zip"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.NotificationsTable.name
    }
  }
}
