locals {
  bucket_name = var.bucket_name == "" ? aws_s3_bucket.b[0].id : var.bucket_name
}

resource "aws_s3_bucket" "b" {
  count         = var.bucket_name == "" ? 1 : 0
  bucket_prefix = "slack-alert-bot"
}

resource "aws_s3_bucket_acl" "b" {
  count      = var.bucket_name == "" ? 1 : 0
  bucket     = aws_s3_bucket.b[0].id
  acl        = "private"
  depends_on = [aws_s3_bucket.b]
}

resource "aws_s3_bucket_versioning" "b" {
  count      = var.bucket_name == "" ? 1 : 0
  bucket     = aws_s3_bucket.b[0].id
  depends_on = [aws_s3_bucket.b]

  versioning_configuration {
    status = "Enabled"
  }
}
