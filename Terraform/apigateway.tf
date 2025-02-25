resource "aws_apigatewayv2_api" "notification_api" {
  name          = "NotificationAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "notification_stage" {
  api_id      = aws_apigatewayv2_api.notification_api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.notification_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.notification_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "notification_route" {
  api_id    = aws_apigatewayv2_api.notification_api.id
  route_key = "POST /send-notification"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gateway" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.notification_api.execution_arn}/*/*"
}
