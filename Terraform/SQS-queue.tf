resource "aws_sqs_queue" "notification_queue" {
  name                       = var.sqs_queue_name
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 30 # must be more than lambda timeout

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notification_dlq.arn
    maxReceiveCount     = 5 # Moves message to DLQ after 5 failed processing attempts
  })
}

# event source mapping(Allow sqs to trigger lambda) - so that SQS automatically invokes Lambda when a new message arrives.
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.notification_queue.arn
  function_name    = aws_lambda_function.notification_lambda.arn
  batch_size       = 5 # Number of messages Lambda should process at a time
}