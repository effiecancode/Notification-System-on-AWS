# capture apigateway logs

resource "aws_apigatewayv2_stage" "notification_stage" {
  api_id      = aws_apigatewayv2_api.notification_api.id
  name        = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn
    format          = jsonencode({
      requestId    = "$context.requestId"
      ip           = "$context.identity.sourceIp"
      requestTime  = "$context.requestTime"
      httpMethod   = "$context.httpMethod"
      routeKey     = "$context.routeKey"
      status       = "$context.status"
    })
  }
}

resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.notification_api.name}"
  retention_in_days = 30
}

# capture SES logs
resource "aws_cloudwatch_log_group" "ses_logs" {
  name              = "/aws/ses/email_logs"
  retention_in_days = 30
}
# capture lambda logs
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/MetadataLoggerLambda"
  retention_in_days = 30
}
