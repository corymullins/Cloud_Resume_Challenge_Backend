# S3 bucket creation, policy, and block public access
resource "aws_s3_bucket" "terraform_state" {
  bucket_prefix = var.terraform_state_bucket_name
}
resource "aws_s3_bucket_acl" "terraform_state_bucket_acl" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
  # test to slow down check
  depends_on = [
    aws_s3_bucket.terraform_state
  ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_bucket_sse" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket ACL, policy, and public access
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.frontend_bucket_name
}
resource "aws_s3_bucket_website_configuration" "frontend_bucket_config" {
  bucket = aws_s3_bucket.frontend_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}
resource "aws_s3_bucket_acl" "frontend_bucket_acl" {
  bucket = aws_s3_bucket.frontend_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
    policy = <<EOT
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity EYTSOKDRCWH6U"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::www.corymullins.com/*"
        }
    ]
}
EOT
}
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_bucket_sse" {
  bucket = aws_s3_bucket.frontend_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket                  = aws_s3_bucket.frontend_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 bucket data to upload
locals {
  mime_types = {
    "css" = "text/css"
    "html" = "text/html"
    "ico"  = "image/vnd.microsoft.icon"
    "jpeg" = "image/jpeg"
    "js"   = "application/javascript"
    "json" = "application/json"
    "map"  = "application/json"
    "pdf"  = "application/pdf"
    "png"  = "image/png"
    "svg"  = "image/svg+xml"
    "txt"  = "text/plain"
  }
}
resource "aws_s3_object" "frontend_data" {
  for_each = fileset("frontend_data/*", "**/*.*")
  bucket = aws_s3_bucket.frontend_bucket.id
  key = each.key
  source = "frontend_data/${each.key}"
  content_type = lookup(tomap(local.mime_types), element(split(".", each.key), length(split(".", each.key)) - 1))
  etag = filemd5("frontend_data/${each.key}")
}