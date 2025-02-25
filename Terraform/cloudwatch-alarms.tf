# Alarm for lambda
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "LambdaErrorAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace          = "AWS/Lambda"
  period             = 60
  statistic          = "Sum"
  threshold          = 1
  alarm_description  = "Triggered when Lambda has errors"
  alarm_actions      = [aws_sns_topic.notification_topic.arn]
  dimensions = {
    FunctionName = aws_lambda_function.notification_lambda.function_name
  }
}


# Alarm for high api gateway latency
resource "aws_cloudwatch_metric_alarm" "api_latency_alarm" {
  alarm_name          = "APIGatewayLatencyAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Latency"
  namespace          = "AWS/ApiGateway"
  period             = 60
  statistic          = "Average"
  threshold          = 2000
  alarm_description  = "Triggered when API Gateway latency exceeds 2 seconds"
  alarm_actions      = [aws_sns_topic.notification_topic.arn]
  dimensions = {
    ApiName = aws_apigatewayv2_api.notification_api.name
  }
}

# Alarm sending email failures
resource "aws_cloudwatch_metric_alarm" "ses_failures_alarm" {
  alarm_name          = "SESFailuresAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "SendFailure"
  namespace          = "AWS/SES"
  period             = 60
  statistic          = "Sum"
  threshold          = 1
  alarm_actions      = [aws_sns_topic.notification_topic.arn]
}

# Alarm for high read usage
resource "aws_cloudwatch_metric_alarm" "dynamodb_high_read_usage" {
  alarm_name          = "DynamoDBReadCapacityHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ConsumedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = 60
  statistic           = "Sum"
  threshold           = 500
  alarm_actions       = [aws_sns_topic.notification_topic.arn]
  dimensions = {
    TableName = aws_dynamodb_table.my_table.name
  }
}

# Alarm for write throttling
resource "aws_cloudwatch_metric_alarm" "dynamodb_write_throttle_alarm" {
  alarm_name          = "DynamoDBWriteThrottle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.notification_topic.arn]
  dimensions = {
    TableName = aws_dynamodb_table.my_table.name
  }
}

# Alarm for lambda execution errors
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "LambdaExecutionErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.notification_topic.arn]
  dimensions = {
    FunctionName = aws_lambda_function.metadata_logger.function_name
  }
}

