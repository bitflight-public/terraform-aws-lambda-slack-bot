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

# Terraform format (apply fixes)
terraform fmt -recursive

# Terraform validation
terraform init -backend=false
terraform validate

# TFLint (HCL linting)
tflint --init
tflint

# Run all pre-commit hooks
pre-commit run --all-files

# Deploy module
terraform apply -var="slack_token=xoxb-..."

# Test Lambda locally (requires deployed function)
aws lambda invoke --function-name handleBotEvent --payload file://test-event.json response.json
```

## Linting & Formatting

This repository uses automated linting for both Python and Terraform/HCL files:

**Terraform/HCL:**
- `terraform fmt` - Canonical formatting for all `.tf` files
- `tflint` - Terraform linter with AWS plugin (configured in `.tflint.hcl`)
- `terraform validate` - Configuration syntax validation

**Python:**
- `flake8` - Python linting with complexity checks

**Pre-commit Hooks:**
Install with `pip install pre-commit && pre-commit install`. Hooks run automatically on commit.

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
- `versions.tf` - Terraform and provider version constraints
- `provider.tf` - AWS provider configuration
- `variables.tf` - Input variable definitions with types and descriptions
- `outputs.tf` - Module output definitions

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

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `slack_token` | string | `""` | Yes | Slack Bot OAuth token (sensitive) |
| `bot_name` | string | `"arnold"` | No | Name of the Slack bot |
| `app_version` | string | `"0.4.4"` | No | Application version |
| `bucket_name` | string | `""` | No | S3 bucket name (creates new if empty) |
| `region` | string | `"eu-west-2"` | No | AWS region |

## Output

The module outputs `invoke_url` - configure this as the Request URL in Slack Event Subscriptions.
