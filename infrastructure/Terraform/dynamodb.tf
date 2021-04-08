
resource "aws_dynamodb_table" "message_notification" {
  name           = "message_notification"
  hash_key       = "message"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "message"
    type = "S"
  }
  
}
