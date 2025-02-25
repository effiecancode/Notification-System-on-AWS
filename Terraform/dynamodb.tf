resource "aws_dynamodb_table" "notifications" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
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
}

