resource "aws_dynamodb_table_item" "counter" {
  table_name = "site_counter"
  hash_key   = aws_dynamodb_table.counter_item.hash_key

  item = <<ITEM
{
  "ID": {"S": "hashing"},
  "ID": {"S": "site"},
  "visits": {"N": "0"}
}
ITEM
}

resource "aws_dynamodb_table" "counter_item" {
  name           = "site_counter"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}