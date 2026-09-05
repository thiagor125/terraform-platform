variable "aws_region" {
  description = "AWS region used by the Terraform lab."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for naming and tagging."
  type        = string
  default     = "terraform-enterprise-lab"
}

variable "github_owner" {
  description = "GitHub repository owner."
  type        = string
  default     = "thiagor125"
}

variable "github_owner_id" {
  description = "Immutable GitHub owner ID used by OIDC subject claims."
  type        = string
  default     = "95186623"
}

variable "github_repository" {
  description = "GitHub repository name."
  type        = string
  default     = "terraform-enterprise-lab"
}

variable "github_repository_id" {
  description = "Immutable GitHub repository ID used by OIDC subject claims."
  type        = string
  default     = "1357752090"
}

variable "github_apply_environment" {
  description = "GitHub Environment allowed to assume the Terraform Apply role."
  type        = string
  default     = "lab-apply"
}
