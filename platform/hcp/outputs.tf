output "hcp_organization" {
  value       = tfe_organization.lab.name
  description = "HCP Terraform organization name."
}

output "hcp_project" {
  value       = tfe_project.lab.name
  description = "HCP Terraform project name."
}

output "hcp_workspace" {
  value       = tfe_workspace.aws_lab.name
  description = "HCP Terraform workspace name."
}

output "hcp_workspace_id" {
  value       = tfe_workspace.aws_lab.id
  description = "HCP Terraform workspace ID."
}

output "aws_plan_role_arn" {
  value       = aws_iam_role.hcp_plan.arn
  description = "AWS IAM role used by HCP Terraform during plan."
}

output "aws_apply_role_arn" {
  value       = aws_iam_role.hcp_apply.arn
  description = "AWS IAM role used by HCP Terraform during apply."
}
