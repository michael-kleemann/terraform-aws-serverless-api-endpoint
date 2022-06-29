data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${var.artifact_folder}/${var.name}"
  output_path = "${var.name}.zip"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_role_policy" {
  count                     = length(var.lambda_policies) == 0 ? 0 : 1
  override_policy_documents = var.lambda_policies
}

resource "aws_iam_role" "lambda_role" {
  name               = "${local.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  for_each   = var.lambda_managed_policies
  policy_arn = each.value
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  count  = length(var.lambda_policies) == 0 ? 0 : 1
  name   = "${local.lambda_name}-policies"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_role_policy[0].json
}

resource "aws_lambda_function" "lambda" {
  description      = "The lambda function which executes your code."
  function_name    = local.lambda_name
  runtime          = "go1.x"
  memory_size      = var.memory
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = var.name
  timeout          = var.timeout
  role             = aws_iam_role.lambda_role.arn
  dynamic "environment" {
    for_each = length(var.environment_vars) > 0 ? [1] : []
    content {
      variables = var.environment_vars
    }
  }
  depends_on = [
    data.archive_file.lambda_zip
  ]
}
