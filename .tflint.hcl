# TFLint configuration for terraform-aws-lambda-slack-bot
# https://github.com/terraform-linters/tflint

config {
  format = "compact"
  plugin_dir = "~/.tflint.d/plugins"

  call_module_type = "local"
}

# Enable the Terraform ruleset (bundled)
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Enable the AWS ruleset
plugin "aws" {
  enabled = true
  version = "0.40.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Ensure all variables have types
rule "terraform_typed_variables" {
  enabled = true
}

# Ensure terraform version constraint exists
rule "terraform_required_version" {
  enabled = true
}

# Ensure all providers have version constraints
rule "terraform_required_providers" {
  enabled = true
}

# Naming conventions
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

# Documentation
rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

# Standard module structure
rule "terraform_standard_module_structure" {
  enabled = true
}

# Unused declarations
rule "terraform_unused_declarations" {
  enabled = true
}

# Deprecated syntax
rule "terraform_deprecated_interpolation" {
  enabled = true
}

# Workspace usage warning
rule "terraform_workspace_remote" {
  enabled = true
}
