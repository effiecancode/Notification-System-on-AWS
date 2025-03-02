
resource "aws_api_gateway_rest_api" "notification_api" {
  name        = "aws_api_gateway_rest_api"
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

# Define the integration between API Gateway and Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.notification_api.id
  resource_id             = aws_api_gateway_resource.notifications.id
  http_method             = aws_api_gateway_method.post_notification.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.notification_lambda.invoke_arn
}

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



resource "aws_lambda_permission" "api_gateway" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.notification_api.execution_arn}/*/*"
}
