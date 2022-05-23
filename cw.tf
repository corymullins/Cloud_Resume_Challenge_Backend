resource "aws_cloudwatch_log_group" "cloudwatch_log" {
  name              = "/aws/lambda/${"visit_counter_lambda"}"
  retention_in_days = 30
}