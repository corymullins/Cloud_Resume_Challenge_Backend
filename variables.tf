variable "api_name" {
  type        = string
  description = "API Gateway name"
}

variable "frontend_bucket_name" {
  type        = string
  description = "S3 bucket name"
}

variable "domain_name" {
  type        = string
  description = "Website domain name"
}

variable "endpoint" {
  type        = string
  description = "endpoint URL"
}

variable "hash_key" {
  type        = string
  description = "DynamoDB hash key"
}

variable "header" {
  type        = string
  description = "website address for CORS"
}

variable "lambda_name" {
  type        = string
  description = "Lambda function name"
}

variable "lambda_uri" {
  type        = string
  description = "Lambda URI"
}

variable "table_name" {
  type        = string
  description = "DynamoDB table name"
}

variable "terraform_state_bucket_name" {
  type        = string
  description = "S3 bucket name"
}

variable "type" {
  type        = string
  description = "DynamoDB attribute type (e.g. S, N)"
}