# DynamoDB table creation
resource "aws_dynamodb_table" "terraform_state" {
  name         = "terraform_state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# DynamoDB table creation
resource "aws_dynamodb_table" "dynamodb_table" {
  name         = "cloud-resume-stats"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "stat"

  attribute {
    name = "stat"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "counter" {
  table_name = aws_dynamodb_table.dynamodb_table.name
  hash_key = aws_dynamodb_table.dynamodb_table.hash_key

  item = <<ITEM
  {
    "stat": {"S": "view-count"},
    "Quantity": {"N": "0"}
  }
  ITEM
}