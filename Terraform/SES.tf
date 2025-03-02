resource "aws_ses_email_identity" "verified_email" {
  email = var.default_email
}

# delivery notifications
resource "aws_ses_identity_notification_topic" "ses_delivery_notifications" {
  topic_arn         = aws_sns_topic.sns_notifications.arn
  notification_type = "Delivery"
  identity          = var.default_email
}

