output "invoke_url" {
  description = "API Gateway endpoint URL for Slack Event Subscriptions configuration"
  value       = format("%s/event-handler", aws_api_gateway_stage.production.invoke_url)
}
