resource "aws_sns_topic" "sns_notifications" {
  name = var.sns_topic_name
}
resource "aws_sns_topic" "ses_notifications" {
  name = var.ses_topic_name
}

# subscribe lambda to SNS
resource "aws_sns_topic_subscription" "ses_subscription" {
  topic_arn = aws_sns_topic.sns_notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notification_lambda.arn
}

# attach SNS to SES with email as identity
resource "aws_ses_identity_notification_topic" "ses_bounce_notifications" {
  topic_arn = aws_sns_topic.sns_notifications.arn
  notification_type = "Bounce"
  identity = var.default_email
}

resource "aws_ses_identity_notification_topic" "ses_complaint_notifications" {
  topic_arn = aws_sns_topic.sns_notifications.arn
  notification_type = "Complaint"
  identity = var.default_email
}
