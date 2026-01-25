# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform module that deploys a Slack bot on AWS using Lambda, API Gateway, S3, and SSM Parameter Store. The bot receives Slack events and responds by reversing text messages. Modernized to Python 3.12 and Terraform 1.6+ (January 2026).

## Build & Validation Commands

```bash
# Python syntax check
python -m py_compile lambda/*.py

# Python linting (errors only)
flake8 lambda/ --select=E9,F63,F7,F82 --show-source

# Python linting (full with warnings)
flake8 lambda/ --max-complexity=10 --max-line-length=127

# Terraform format check
terraform fmt -check -recursive

# Terraform validation
terraform init -backend=false
terraform validate

# Deploy module
terraform apply -var="slack_token=xoxb-..."

# Test Lambda locally (requires deployed function)
aws lambda invoke --function-name handleBotEvent --payload file://test-event.json response.json
```

## Architecture

```
Slack Event API → API Gateway (POST /event-handler) → Lambda (Python 3.12) → Slack API
                                                            ↓
                                                    SSM Parameter Store
                                                    (token verification)
```

**Key Resources:**
- `lambda.tf` - Lambda function definition, handler: `index.lambda_handler`
- `api_gateway.tf` - REST API with `/event-handler` POST endpoint
- `iam.tf` - IAM roles for Lambda with SSM access
- `main.tf` - S3 bucket for Lambda deployment package (conditionally created)

**Lambda Functions:**
- `lambda/index.py` - Main Slack event handler (challenge verification, message processing)
- `lambda/bot_functions.py` - SSM parameter helpers (`get_param_map`, `put_param_map`)
- `lambda/index_sns.py` - Alternative SNS-triggered handler

## Modernization Workflow

This repo includes a brownfield modernization framework in `.claude/`. Use:
- `/modernize --init` - Initialize new modernization project
- `/modernize --resume` - Resume from checkpoint
- `/modernize --status` - View current progress

Specialist agents in `.claude/agents/`: architecture-reviewer, security-auditor, testing-specialist, dependency-manager.

## Variables

| Variable | Default | Required |
|----------|---------|----------|
| `slack_token` | `""` | Yes |
| `bot_name` | `"arnold"` | No |
| `app_version` | `"0.4.4"` | No |
| `bucket_name` | `""` (creates new) | No |
| `region` | `"eu-west-2"` | No |

## Output

The module outputs `invoke_url` - configure this as the Request URL in Slack Event Subscriptions.
