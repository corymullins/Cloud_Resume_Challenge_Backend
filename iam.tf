# Lambda create role and permissions
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_resume_counter_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}

resource "aws_iam_policy" "lambda_role_permissions" {
  name        = "lambda_resume_counter_role_permissions"
  description = "Lambda role persmissions to access DynamoDB and CloudWatch logs."
  policy      = data.aws_iam_policy_document.lambda_role_permissions.json
}

resource "aws_iam_role_policy_attachment" "lambda_role_permissions_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_role_permissions.arn
}

# Lambda function IAM role
data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Lambda function permissions for DyanmoDB and CloudWatch logs
data "aws_iam_policy_document" "lambda_role_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:GetItem"
    ]
    resources = ["${aws_dynamodb_table.dynamodb_table.arn}"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# S3 bucket policy
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cf_oai.iam_arn]
    }
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.frontend_bucket.arn]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cf_oai.iam_arn]
    }
  }
}