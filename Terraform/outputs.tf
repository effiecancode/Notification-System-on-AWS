
# private data subnet az1 id
output "private_data_subnet_az1_id" {
  value = aws_subnet.private_data_subnet_az1.id
}

# SQS
output "sqs_queue_url" {
  value = aws_sqs_queue.notification_queue.url
}

output "sqs_dlq_url" {
  value = aws_sqs_queue.notification_dlq.url
}