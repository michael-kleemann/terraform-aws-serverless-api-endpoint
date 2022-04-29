locals {
  lambda_name             = "${var.prefix}${var.name}${var.suffix}"
  resource_id             = var.resource.new_path != null ? aws_api_gateway_resource.resource[0].id : data.aws_api_gateway_resource.resource[0].id
  resource_path           = var.resource.new_path != null ? aws_api_gateway_resource.resource[0].path : data.aws_api_gateway_resource.resource[0].path
  resource_last_path_part = var.resource.new_path != null ? aws_api_gateway_resource.resource[0].path_part : data.aws_api_gateway_resource.resource[0].path_part
  has_iam_method_policies = var.authorization.auth_type == "AWS_IAM" && can(length(var.authorization.allow_for) > 0)
  has_authorizer_attached = var.authorization.auth_type == "CUSTOM" && var.authorization.authorizer != null
}
