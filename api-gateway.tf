data "aws_api_gateway_rest_api" "rest_api" {
  name = var.api_name
}

data "aws_iam_policy_document" "invoke_policy" {
  count = local.has_iam_method_policies ? 1 : 0

  statement {
    sid    = var.name
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "execute-api:Invoke"
    ]
    resources = [
      "${data.aws_api_gateway_rest_api.rest_api.execution_arn}:*:${var.http_method}:${local.resource_path}"
    ]
    dynamic "condition" {
      for_each = var.authorization.allow_for
      content {
        test     = condition.value.operation
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

data "aws_api_gateway_resource" "resource" {
  count       = var.resource.existing == null ? 0 : 1
  rest_api_id = data.aws_api_gateway_rest_api.rest_api.id
  path        = var.resource.existing.path
}

resource "aws_api_gateway_resource" "resource" {
  count       = var.resource.new_path == null ? 0 : 1
  rest_api_id = data.aws_api_gateway_rest_api.rest_api.id
  path_part   = var.resource.new_path.last_path_part
  parent_id   = var.resource.new_path.parent_resource_id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = data.aws_api_gateway_rest_api.rest_api.id
  resource_id   = local.resource_id
  http_method   = var.http_method
  authorization = var.authorization.auth_type
  authorizer_id = local.has_authorizer_attached ? var.authorization.authorizer.id : null
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = data.aws_api_gateway_rest_api.rest_api.id
  resource_id             = local.resource_id
  http_method             = aws_api_gateway_method.method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = data.aws_api_gateway_rest_api.rest_api.id
  stage_name  = var.stage_name
  method_path = "${local.resource_last_path_part}/${var.http_method}"

  settings {
    logging_level = var.log_level
  }
}
