locals {
  bucket_name = "${var.bucket_name == "" ? aws_s3_bucket.b.0.id : var.bucket_name}"
}

resource "aws_s3_bucket" "b" {
  count         = "${var.bucket_name == "" ? 1 : 0}"
  bucket_prefix = "slack-alert-bot"
  acl           = "private"

  versioning {
    enabled = true
  }
}
