resource "aws_apigatewayv2_api" "notification_api" {
  name          = "NotificationAPI"
  protocol_type = "HTTP"
}
resource "aws_api_gateway_rest_api" "notification_api" {
  name        = "NotificationAPI"
  description = "API Gateway for notifications"
}

resource "aws_api_gateway_resource" "notifications" {
  rest_api_id = aws_api_gateway_rest_api.notification_api.id
  parent_id   = aws_api_gateway_rest_api.notification_api.root_resource_id
  path_part   = "notifications"
}

resource "aws_api_gateway_method" "post_notification" {
  rest_api_id   = aws_api_gateway_rest_api.notification_api.id
  resource_id   = aws_api_gateway_resource.notifications.id
  http_method   = "POST"
  authorization = "NONE" # Use "AWS_IAM" or "COGNITO_USER_POOLS" for security
}

resource "aws_apigatewayv2_stage" "notification_stage" {
  api_id      = aws_apigatewayv2_api.notification_api.id
  name        = "prod"
  auto_deploy = true
}

# resource "aws_apigateway_stage" "notification_stage" {
#   api_id      = aws_apigateway_api.notification_api.id
#   name        = "prod"
#   auto_deploy = true
# }
resource "aws_api_gateway_stage" "notification_stage" {
  deployment_id = aws_api_gateway_deployment.notification_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.notification_api.id
  stage_name    = "prod"
}

# api gatway deployment
resource "aws_api_gateway_deployment" "notification_deployment" {
  rest_api_id = aws_api_gateway_rest_api.notification_api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.notification_api))
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.notification_api.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
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
