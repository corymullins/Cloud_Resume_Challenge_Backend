
# Lambda function creation
resource "aws_lambda_function" "lambda" {
  filename = "lambda_code/resume_counter.zip"
  function_name = "resume_counter"
  role          = aws_iam_role.lambda_role.arn
  handler = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("lambda_code/resume_counter.zip")
  runtime = "python3.9"
  depends_on = [
    aws_cloudwatch_log_group.cloudwatch_log,
    aws_iam_role.lambda_role,
    aws_iam_role_policy_attachment.lambda_role_permissions_attachment
  ]
}

resource "aws_lambda_permission" "api_gw_access" {
  statement_id  = "Allowlambda_apiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda_api.execution_arn}/*/*"
}
