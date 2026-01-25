variable "region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "eu-west-2"
}

variable "app_version" {
  description = "Version of the Slack bot application"
  type        = string
  default     = "0.4.4"
}

variable "slack_token" {
  description = "Slack Bot OAuth token (xoxb-...) for API authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "bot_name" {
  description = "Name of the Slack bot, used for resource naming"
  type        = string
  default     = "arnold"
}

variable "bucket_name" {
  description = "Existing S3 bucket name for Lambda deployment package. If empty, a new bucket will be created"
  type        = string
  default     = ""
}
