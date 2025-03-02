# Private Data Subnet AZ1 ID
output "private_data_subnet_az1_id" {
  value = aws_subnet.private_data_subnet_az1.id
}

# SQS Queue URLs
output "sqs_queue_url" {
  value = aws_sqs_queue.notification_queue.url
}

output "sqs_dlq_url" {
  value = aws_sqs_queue.notification_dlq.url
}

# DynamoDB Table Name
output "dynamodb_table_name" {
  value = aws_dynamodb_table.NotificationsTable.name
}

# SNS Topics
output "sns_topic_arn" {
  value = aws_sns_topic.sns_notifications.arn
}

output "ses_topic_arn" {
  value = aws_sns_topic.ses_notifications.arn
}

# SES Verified Email Identity
output "ses_verified_email" {
  value = var.default_email
}

# Lambda Function ARN (if applicable)
output "lambda_function_arn" {
  value = aws_lambda_function.notification_lambda.arn
}

# API Gateway Endpoint (if applicable)
output "api_gateway_url" {
  value = aws_api_gateway_stage.notification_stage.invoke_url
}


