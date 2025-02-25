resource "aws_sns_topic" "notification_topic" {
  name = var.sns_topic_name
}

# subscribe lambda to SNS
resource "aws_sns_topic_subscription" "ses_subscription" {
  topic_arn = aws_sns_topic.ses_notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notification_lambda.arn
}

# attach SNS to SES
resource "aws_ses_identity_notification_topic" "ses_bounce_notifications" {
  topic_arn = aws_sns_topic.ses_notifications.arn
  notification_type = "Bounce"
  identity = aws_ses_domain_identity.ses_domain.domain
}

resource "aws_ses_identity_notification_topic" "ses_complaint_notifications" {
  topic_arn = aws_sns_topic.ses_notifications.arn
  notification_type = "Complaint"
  identity = aws_ses_domain_identity.ses_domain.domain
}
