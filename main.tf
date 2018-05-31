variable "app_version" {
  default = "0.4.4"
}

variable "slack_token" {
  default = ""
}

variable "bot_name" {
  default = "arnold"
}

variable "bucket_name" {
  default = ""
}

locals {
  bucket_name = "${var.bucket_name == "" ? aws_s3_bucket.b.0.id : var.bucket_name}"
}

resource "aws_api_gateway_rest_api" "bot" {
  name        = "${var.bot_name}"
  description = "${var.bot_name} for pushing system alerts to slack."
}

resource "aws_api_gateway_resource" "event_handler" {
  rest_api_id = "${aws_api_gateway_rest_api.bot.id}"
  parent_id   = "${aws_api_gateway_rest_api.bot.root_resource_id}"
  path_part   = "event-handler"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.bot.id}"
  resource_id   = "${aws_api_gateway_resource.event_handler.id}"
  http_method   = "POST"
  authorization = "NONE"
}

# resource "aws_api_gateway_method" "method_root" {
#   rest_api_id   = "${aws_api_gateway_rest_api.bot.id}"
#   resource_id   = "${aws_api_gateway_rest_api.bot.root_resource_id}"
#   http_method   = "ANY"
#   authorization = "NONE"
# }
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.bot.id}"
  resource_id = "${aws_api_gateway_method.method.resource_id}"
  http_method = "${aws_api_gateway_method.method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.default.invoke_arn}"
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.bot.id}"
  resource_id = "${aws_api_gateway_resource.event_handler.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"

  response_models = {
    "application/json" = "Empty"
  }

  status_code = "200"
}

resource "aws_api_gateway_integration_response" "response" {
  rest_api_id = "${aws_api_gateway_rest_api.bot.id}"
  resource_id = "${aws_api_gateway_resource.event_handler.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"

  #   # Transforms the backend JSON response to XML
  #   response_templates {
  #     "application/xml" = <<EOF
  # #set($inputRoot = $input.path('$'))
  # <?xml version="1.0" encoding="UTF-8"?>
  # <message>
  #     $inputRoot.body
  # </message>
  # EOF
  #   }
  depends_on = ["aws_api_gateway_integration.lambda"]
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = ["aws_api_gateway_integration.lambda"]

  rest_api_id = "${aws_api_gateway_rest_api.bot.id}"
  stage_name  = "production"

  variables = {
    "bot_name" = "${var.bot_name}"
    "version"  = "${var.app_version}"
  }
}

output "invoke_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}"
}

data "aws_caller_identity" "default" {}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.default.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.default.account_id}:${aws_api_gateway_rest_api.bot.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.event_handler.path}"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/index.py"
  output_path = "${path.module}/${var.app_version}_index.zip"
}

resource "aws_s3_bucket" "b" {
  count         = "${var.bucket_name == "" ? 1 : 0}"
  bucket_prefix = "slack-alert-bot"
  acl           = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket     = "${local.bucket_name}"
  key        = "v${var.app_version}/${var.app_version}_index.zip"
  source     = "${data.archive_file.lambda.output_path}"
  etag       = "${md5(file(data.archive_file.lambda.output_path))}"
  depends_on = ["data.archive_file.lambda"]
}

resource "aws_lambda_function" "default" {
  function_name = "handleBotEvent"
  depends_on    = ["aws_s3_bucket_object.object"]
  s3_bucket     = "${local.bucket_name}"
  s3_key        = "${aws_s3_bucket_object.object.key}"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "index.lambda_handler"
  runtime = "python3.6"

  role = "${aws_iam_role.lambda_exec.arn}"

  environment {
    variables = {
      BOT_TOKEN = "${var.slack_token}"
      BOT_VERSION   = "${var.app_version}"
    }
  }
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_exec" {
  name = "${var.bot_name}-lambda-role"

  assume_role_policy = "${data.aws_iam_policy_document.ssm_role_policy.json}"
}
data "aws_iam_policy_document" "ssm_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com", "lambda.amazonaws.com", "sns.amazonaws.com"]
    }
  }


}

data "aws_iam_policy_document" "ssm_parameter_policy" {
    statement {
    actions = [
    "ssm:DescribeParameter*",
    "ssm:GetParameter*",
    "ssm:PutParameter*",
    "ssm:DeleteParameter",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy_attachment" "attach_ssm_parameter_policy" {
  role       = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "${aws_iam_policy.ssm_parameter_policy.arn}"
}
resource "aws_iam_policy" "ssm_parameter_policy" {
  name        = "ssm_parameter_policy_${var.app_version}_${var.bot_name}"
  description = "Access to the Parameter store for ${var.app_version}_${var.bot_name}"
  policy      = "${data.aws_iam_policy_document.ssm_parameter_policy.json}"
}

resource "aws_iam_role_policy_attachment" "attach_ssm_automation" {
  role       = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}
# resource "aws_lambda_permission" "allow_cloudwatch" {
#   statement_id   = "AllowExecutionFromCloudWatch"
#   action         = "lambda:InvokeFunction"
#   function_name  = "${aws_lambda_function.default.function_name}"
#   principal      = "events.amazonaws.com"
#   source_arn     = "arn:aws:events:eu-west-1:${data.aws_caller_identity.default.account_id}:rule/RunDaily"
#   qualifier      = "${aws_lambda_alias.default.name}"
# }

# resource "aws_lambda_alias" "default" {
#   name             = "testalias"
#   description      = "a sample description"
#   function_name    = "${aws_lambda_function.test_lambda.function_name}"
#   function_version = "$LATEST"
# }
#ssm:DescribeParameters
# resource "aws_iam_role_policy_attachment" "attach" {
#   role       = "${aws_iam_role.lambda_exec.name}"
#   policy_arn = "${aws_iam_policy.policy.arn}"
# }
resource "aws_iam_role_policy_attachment" "basic" {
  role       = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# resource "aws_api_gateway_method" "proxy" {
#   rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
#   resource_id   = "${aws_api_gateway_resource.proxy.id}"
#   http_method   = "ANY"
#   authorization = "NONE"
# }


# resource "aws_api_gateway_method" "proxy_root" {
#   rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
#   resource_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
#   http_method   = "ANY"
#   authorization = "NONE"
# }


# resource "aws_api_gateway_integration" "lambda_root" {
#   rest_api_id = "${aws_api_gateway_rest_api.example.id}"
#   resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
#   http_method = "${aws_api_gateway_method.proxy_root.http_method}"


#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = "${aws_lambda_function.example.invoke_arn}"
# }


# resource "aws_api_gateway_deployment" "example" {
#   depends_on = [
#     "aws_api_gateway_integration.lambda",
#     "aws_api_gateway_integration.lambda_root",
#   ]


#   rest_api_id = "${aws_api_gateway_rest_api.example.id}"
#   stage_name  = "test"
# }


# output "base_url" {
#   value = "${aws_api_gateway_deployment.example.invoke_url}"
# }

