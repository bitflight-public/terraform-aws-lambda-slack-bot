# terraform-aws-lambda-slack-bot

[![Validate](https://github.com/bitflight-public/terraform-aws-lambda-slack-bot/actions/workflows/validate.yml/badge.svg)](https://github.com/bitflight-public/terraform-aws-lambda-slack-bot/actions/workflows/validate.yml)

A Terraform module that deploys a Slack bot on AWS using Lambda, API Gateway, and S3. The bot receives events from Slack's Event API and responds by reversing the text sent to it.

> **Status**: ✅ **FUNCTIONAL AND MODERNIZED** (January 2026)
> - Updated to Python 3.12 runtime (previously deprecated 3.6)
> - Updated to Terraform 1.6+ compatible syntax
> - All syntax errors fixed and validated
> - Automated CI/CD validation in place

## Overview

This module creates the necessary AWS infrastructure to run a Slack bot that:
- Receives events from Slack via an API Gateway endpoint
- Processes events using an AWS Lambda function (Python 3.12 runtime)
- Stores Slack tokens securely in AWS Systems Manager Parameter Store
- Reverses text messages sent to the bot and posts them back to the Slack channel

## Architecture

The module provisions:
- **AWS Lambda Function**: Handles incoming Slack events and processes messages
- **API Gateway**: Provides an HTTP endpoint for Slack to send events
- **S3 Bucket**: Stores the Lambda deployment package
- **IAM Roles & Policies**: Grants Lambda permissions to access SSM Parameter Store and CloudWatch Logs
- **SSM Parameter Store**: Securely stores the Slack verification token

## Prerequisites

Before using this module, you need:

1. **AWS Account** with appropriate credentials configured
2. **Terraform** installed (version 1.6 or higher recommended)
3. **Slack Workspace** with admin access to create a Slack app
4. **Slack Bot Token** from your Slack app

### Setting up a Slack App

1. Go to [Slack API Apps](https://api.slack.com/apps)
2. Click "Create New App"
3. Choose "From scratch" and provide an app name and workspace
4. Navigate to "OAuth & Permissions" and add the following Bot Token Scopes:
   - `chat:write` - To send messages
   - `channels:history` - To read messages from channels
   - `im:history` - To read direct messages
5. Install the app to your workspace
6. Copy the "Bot User OAuth Token" (starts with `xoxb-`)
7. Navigate to "Event Subscriptions" and enable events
   - You'll need to set the Request URL after deploying this module (use the `invoke_url` output)
8. Subscribe to bot events:
   - `message.im` - Messages sent to the bot in direct messages
   - `message.channels` - Messages in channels where the bot is added
9. Reinstall your app if prompted

## Usage

### Basic Example

```hcl
module "slack_bot" {
  source = "github.com/bitflight-public/terraform-aws-lambda-slack-bot"

  slack_token = "xoxb-your-slack-bot-token"
  bot_name    = "my-slack-bot"
  app_version = "0.4.4"
}

output "slack_bot_url" {
  value       = module.slack_bot.invoke_url
  description = "Use this URL as the Request URL in Slack Event Subscriptions"
}
```

### Using an Existing S3 Bucket

```hcl
module "slack_bot" {
  source = "github.com/bitflight-public/terraform-aws-lambda-slack-bot"

  slack_token = "xoxb-your-slack-bot-token"
  bot_name    = "my-slack-bot"
  app_version = "0.4.4"
  bucket_name = "my-existing-lambda-bucket"
}
```

### Complete Example with Custom Region

```hcl
terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = "us-east-1"
}

module "slack_bot" {
  source = "github.com/bitflight-public/terraform-aws-lambda-slack-bot"

  slack_token = var.slack_token  # Store sensitive values in terraform.tfvars
  bot_name    = "arnold"
  app_version = "0.4.4"
}

output "api_gateway_url" {
  value       = module.slack_bot.invoke_url
  description = "Configure this URL in Slack Event Subscriptions"
}
```

## Configuration

After deploying the module:

1. Copy the `invoke_url` output value
2. Go to your Slack app's Event Subscriptions page
3. Paste the URL into the "Request URL" field
4. Slack will send a challenge request to verify the endpoint
5. The Lambda function will automatically verify and save the token
6. Click "Save Changes"

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `slack_token` | Slack Bot User OAuth Token (xoxb-...) | `string` | `""` | yes |
| `bot_name` | Name of the bot (used for resource naming) | `string` | `"arnold"` | no |
| `app_version` | Version of the bot application | `string` | `"0.4.4"` | no |
| `bucket_name` | S3 bucket name for Lambda code (creates new bucket if empty) | `string` | `""` | no |
| `region` | AWS region to deploy resources | `string` | `"eu-west-2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| `invoke_url` | API Gateway endpoint URL for Slack Event Subscriptions |

## How It Works

1. **Event Reception**: Slack sends events to the API Gateway endpoint
2. **Challenge Verification**: On first setup, the Lambda function responds to Slack's challenge
3. **Token Storage**: The verification token is stored in SSM Parameter Store
4. **Message Processing**: When a user sends a message to the bot:
   - The Lambda function receives the event
   - It verifies the token matches the stored value
   - It reverses the text of the message
   - It posts the reversed text back to the Slack channel using the Slack API

## Security

- Slack bot tokens are stored securely in AWS Systems Manager Parameter Store
- IAM roles follow the principle of least privilege
- The S3 bucket has versioning enabled by default
- API Gateway endpoint validates Slack tokens before processing events

## Customization

To customize the bot's behavior, modify the Lambda function code in `lambda/index.py`. The current implementation reverses text messages, but you can extend it to:
- Integrate with other AWS services
- Respond to different event types
- Implement custom slash commands
- Add natural language processing
- Integrate with external APIs

## Testing

You can test the Lambda function locally using the provided `test-event.json` file:

```bash
# Test locally (requires AWS credentials configured)
# Note: The function name is "handleBotEvent" as defined in lambda.tf
aws lambda invoke \
  --function-name handleBotEvent \
  --payload file://test-event.json \
  response.json
```

## Troubleshooting

### Slack shows "Your URL didn't respond with the challenge"

- Ensure the Lambda function has been deployed successfully
- Check CloudWatch Logs for any errors
- Verify the API Gateway endpoint is accessible

### Bot doesn't respond to messages

- Verify the bot is added to the channel or DM
- Check that Event Subscriptions are properly configured
- Review CloudWatch Logs for the Lambda function
- Ensure the Slack token has the necessary permissions

### SSM Parameter not found error

- The parameter is created automatically during the challenge verification
- Ensure the first request from Slack (challenge) completed successfully

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| aws provider | >= 5.0 |
| archive provider | >= 2.0 |
| python | 3.12 |

## Development

This project includes automated linting and formatting tools:

### Pre-commit Hooks (prek)

Install [prek](https://prek.j178.dev/) hooks for automatic validation:

```bash
pip install prek
prek install
```

### Linting Commands

```bash
# Terraform formatting
terraform fmt -check -recursive    # Check formatting
terraform fmt -recursive           # Apply formatting

# TFLint (Terraform linting with AWS plugin)
tflint --init                      # Initialize plugins
tflint                             # Run linter

# Python linting with Ruff
ruff check lambda/                 # Check for issues
ruff check lambda/ --fix           # Auto-fix issues

# Python formatting with Ruff
ruff format --check lambda/        # Check formatting
ruff format lambda/                # Apply formatting

# Run all prek hooks
prek run --all-files
```

### Configuration Files

- `.tflint.hcl` - TFLint configuration with AWS ruleset
- `.pre-commit-config.yaml` - Prek hook configuration
- `ruff.toml` - Ruff linter/formatter configuration
- `versions.tf` - Terraform and provider version constraints

## Recent Updates (January 2026)

This module has been modernized and validated:

- ✅ **Python Runtime Updated**: Upgraded from deprecated Python 3.6 to Python 3.12
- ✅ **Terraform Modernized**: Updated to Terraform 1.6+ syntax, removing deprecated interpolation
- ✅ **Syntax Errors Fixed**: Corrected all Python indentation and import errors
- ✅ **AWS Provider Updated**: Compatible with AWS provider v5.0+
- ✅ **CI/CD Added**: GitHub Actions workflow validates both Python and Terraform code
- ✅ **Dependencies Documented**: Added requirements.txt for Python dependencies
- ✅ **HCL Linting Added**: TFLint with AWS plugin for Terraform best practices
- ✅ **Pre-commit Hooks**: Automated formatting and linting with prek
- ✅ **Variable Types**: All variables now have explicit types and descriptions
- ✅ **Ruff Integration**: Fast Python linting and formatting with Ruff

## License

This project is provided as-is without warranty. Feel free to use and modify it for your needs.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## Authors

Maintained by the Bitflight team.