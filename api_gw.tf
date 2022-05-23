# API Gateway creation
resource "aws_api_gateway_rest_api" "lambda_api" {
  name        = "cloud-resume-challenge"
  description = "API to integrate Lambda and DynamoDB with a S3-hosted static website."
}

# Cross-Origin Resource Sharing Integration - GET
resource "aws_api_gateway_method" "root_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "get_200_status" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method = aws_api_gateway_method.root_get_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [aws_api_gateway_method.root_get_method]
}
resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_api.id
  resource_id             = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method             = aws_api_gateway_method.root_get_method.http_method
  integration_http_method = aws_api_gateway_method.root_get_method.http_method
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda.invoke_arn
  depends_on = [
    aws_api_gateway_method.root_get_method,
    aws_api_gateway_method.proxy_base
  ]
}
resource "aws_api_gateway_integration_response" "get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method = aws_api_gateway_method.root_get_method.http_method
  status_code = aws_api_gateway_method_response.get_200_status.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'application/json'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET, OPTIONS, POST, PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.header}'"
  }
  depends_on = [
    aws_api_gateway_method_response.get_200_status,
    aws_api_gateway_integration.get_integration
  ]
}

# Cross-Origin Resource Sharing Integration - OPTIONS
resource "aws_api_gateway_method" "root_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "options_200_status" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method = aws_api_gateway_method.root_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [aws_api_gateway_method.root_options_method]
}
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id      = aws_api_gateway_rest_api.lambda_api.id
  resource_id      = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method      = aws_api_gateway_method.root_options_method.http_method
  content_handling = "CONVERT_TO_TEXT"
  type             = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200}"
  }
  depends_on = [aws_api_gateway_method.root_options_method]
}
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method = aws_api_gateway_method.root_options_method.http_method
  status_code = aws_api_gateway_method_response.options_200_status.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.header}'"
  }
  depends_on = [aws_api_gateway_method_response.options_200_status]
}
resource "aws_api_gateway_gateway_response" "response_4XX" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  response_type = "DEFAULT_4XX"
  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'${var.header}'"
  }
}
resource "aws_api_gateway_gateway_response" "response_5XX" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  response_type = "DEFAULT_5XX"
  response_templates = {
    "application/json" = "{'message':$context.error.messageString'}"
  }
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'${var.header}'"
  }
}

# Lambda proxy deployment
resource "aws_api_gateway_method" "proxy_base" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "lambda_base" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_api.id
  resource_id             = aws_api_gateway_method.proxy_base.resource_id
  http_method             = aws_api_gateway_method.proxy_base.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "apigwdeploy" {
  depends_on = [
    aws_api_gateway_integration.lambda_base,
    aws_api_gateway_method.root_get_method,
    aws_api_gateway_method.root_options_method
  ]
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  stage_name  = "prod"
}
output "URL" {
  value = aws_api_gateway_deployment.apigwdeploy.invoke_url
}
