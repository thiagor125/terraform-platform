output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "terraform_plan_role_arn" {
  description = "IAM Role assumed by GitHub Actions for Terraform Plan."
  value       = aws_iam_role.terraform_plan.arn
}

output "terraform_apply_role_arn" {
  description = "IAM Role assumed by GitHub Actions for Terraform Apply."
  value       = aws_iam_role.terraform_apply.arn
}

output "github_apply_environment" {
  description = "GitHub Environment allowed to perform Terraform Apply."
  value       = var.github_apply_environment
}
