resource "aws_api_gateway_rest_api" "bot" {
  name        = var.bot_name
  description = "${var.bot_name} for pushing system alerts to slack."
}

resource "aws_api_gateway_resource" "event_handler" {
  rest_api_id = aws_api_gateway_rest_api.bot.id
  parent_id   = aws_api_gateway_rest_api.bot.root_resource_id
  path_part   = "event-handler"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.bot.id
  resource_id   = aws_api_gateway_resource.event_handler.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.bot.id
  resource_id = aws_api_gateway_method.method.resource_id
  http_method = aws_api_gateway_method.method.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.default.invoke_arn
}

resource "aws_api_gateway_method_response" "ok_200" {
  rest_api_id = aws_api_gateway_rest_api.bot.id
  resource_id = aws_api_gateway_resource.event_handler.id
  http_method = aws_api_gateway_method.method.http_method

  response_models = {
    "application/json" = "Empty"
  }

  status_code = "200"
}

resource "aws_api_gateway_integration_response" "response" {
  rest_api_id = aws_api_gateway_rest_api.bot.id
  resource_id = aws_api_gateway_resource.event_handler.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = aws_api_gateway_method_response.ok_200.status_code
  depends_on  = [aws_api_gateway_integration.lambda]
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration_response.response
  ]

  rest_api_id = aws_api_gateway_rest_api.bot.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.event_handler.id,
      aws_api_gateway_method.method.id,
      aws_api_gateway_integration.lambda.id,
      aws_api_gateway_integration_response.response.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "production" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.bot.id
  stage_name    = "production"

  variables = {
    "bot_name" = var.bot_name
    "version"  = var.app_version
  }
}
