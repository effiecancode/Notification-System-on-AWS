resource "aws_lambda_function" "notification_lambda" {
  filename      = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")
  function_name = "notificationHandler"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 25  # Ensure it's less than SQS visibility timeout

  tracing_config {
    # allow AWS X-Ray to trace requests as they travel through your application
    mode = "Active"
  }

  environment {
    variables = {
      SES_SENDER_EMAIL = var.default_email
      SQS_QUEUE_URL    = aws_sqs_queue.notification_queue.url
      DYNAMODB_TABLE   = aws_dynamodb_table.notifications.name
      SNS_TOPIC_ARN    = aws_sns_topic.notification_topic.arn
    }
  }
}

# Create the DLQ
resource "aws_sqs_queue" "notification_dlq" {
  name                      = "notification-dlq"
  message_retention_seconds = 1209600  # Messages retained for 14 days
}
