locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region

  state_bucket_name = "${var.project_name}-${local.account_id}-${local.region}-tfstate"

  github_repository_full_name = "${var.github_owner}/${var.github_repository}"

  github_oidc_repository = "${var.github_owner}@${var.github_owner_id}/${var.github_repository}@${var.github_repository_id}"

  github_plan_subject = "repo:${local.github_oidc_repository}:pull_request"

  github_apply_subject = "repo:${local.github_oidc_repository}:environment:${var.github_apply_environment}"

  common_tags = {
    Project    = var.project_name
    ManagedBy  = "Terraform"
    Purpose    = "GitHubOIDC"
    Repository = local.github_repository_full_name
  }
}
