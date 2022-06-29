output "resource" {
  value = var.resource.new_path != null ? aws_api_gateway_resource.resource[0] : data.aws_api_gateway_resource.resource[0]
}

output "method" {
  value = aws_api_gateway_method.method
}

output "integration" {
  value = aws_api_gateway_integration.integration
}

output "invoke_policy" {
  value = local.has_iam_method_policies ? data.aws_iam_policy_document.invoke_policy[0].json : null
}
