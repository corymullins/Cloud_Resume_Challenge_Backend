# KMS key creation and alias
resource "aws_kms_key" "terraform_bucket_key" {
  description             = "Key for encryption of bucket objects."
  deletion_window_in_days = 14
  enable_key_rotation     = true
}
resource "aws_kms_alias" "terraform_bucket_key_alias" {
  name          = "alias/terraform_key"
  target_key_id = aws_kms_key.terraform_bucket_key.key_id
}