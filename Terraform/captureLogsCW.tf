
# Create log groups
# capture apigateway logs

resource "aws_cloudwatch_log_group" "api_gw_logs" {
  # apigateway uses paths to maintain consistency with AWS's logging hierarchy
  name              = "/aws/apigateway/${aws_api_gateway_rest_api.notification_api.id}"
  retention_in_days = 30
}

# capture SES logs
resource "aws_cloudwatch_log_group" "ses_logs" {
  # SES uses paths to follow AWS's standardized logging patterns
  name              = "/aws/ses/email_logs"
  retention_in_days = 30
}
# capture lambda logs
resource "aws_cloudwatch_log_group" "lambda_logs" {
  # Lambda uses paths to align with AWS's service-specific logging structure
  name              = "/aws/lambda/MetadataLoggerLambda"
  retention_in_days = 30
}
# capture SQS logs
resource "aws_cloudwatch_log_group" "sqs_logs" {
  name = var.sqs_queue_name
}
