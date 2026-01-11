output "invoke_url" {
  value = format("%s/event-handler", aws_api_gateway_stage.production.invoke_url)
}
