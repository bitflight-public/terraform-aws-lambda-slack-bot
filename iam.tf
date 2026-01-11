resource "aws_iam_role" "lambda_exec" {
  name = "${var.bot_name}-lambda-role"

  assume_role_policy = data.aws_iam_policy_document.ssm_role_policy.json
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
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.ssm_parameter_policy.arn
}

resource "aws_iam_policy" "ssm_parameter_policy" {
  name        = "ssm_parameter_policy_${var.app_version}_${var.bot_name}"
  description = "Access to the Parameter store for ${var.app_version}_${var.bot_name}"
  policy      = data.aws_iam_policy_document.ssm_parameter_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_ssm_automation" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
