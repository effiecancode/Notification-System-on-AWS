resource "aws_dynamodb_table" "NotificationsTable" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = var.dynamodb_table_name
    Environment = var.environment
  }
}



# enable detailed monitoring for dynamodb
#   stream_enabled   = true
#   stream_view_type = "NEW_AND_OLD_IMAGES" # Enables Change Streams

#   point_in_time_recovery {
#     enabled = true
#   }

#   tags = {
#     Name = "MyDynamoDBTable"
#   }


