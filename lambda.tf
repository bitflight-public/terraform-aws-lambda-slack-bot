# Lambda
data "aws_caller_identity" "default" {}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.arn
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.default.account_id}:${aws_api_gateway_rest_api.bot.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.event_handler.path}"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda/index.zip"
}

resource "aws_s3_object" "object" {
  bucket     = local.bucket_name
  key        = "v${var.bot_name}/${var.app_version}_index.zip"
  source     = data.archive_file.lambda.output_path
  etag       = filemd5(data.archive_file.lambda.output_path)
  depends_on = [data.archive_file.lambda]
}

resource "aws_lambda_function" "default" {
  function_name = "handleBotEvent"
  depends_on    = [aws_s3_object.object]
  s3_bucket     = local.bucket_name
  s3_key        = aws_s3_object.object.key

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "index.lambda_handler"

  runtime = "python3.12"
  role    = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      BOT_TOKEN   = var.slack_token
      BOT_VERSION = var.app_version
    }
  }
}
