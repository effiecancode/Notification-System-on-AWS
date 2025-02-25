resource "aws_sqs_queue" "notification_queue" {
  name                      = var.sqs_queue_name
  message_retention_seconds = 86400
  visibility_timeout_seconds = 30
}
