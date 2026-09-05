terraform {
  required_version = ">= 1.6.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.80.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "tfe" {
  hostname = "app.terraform.io"
}

locals {
  hcp_hostname = "app.terraform.io"
  audience     = "aws.workload.identity"

  plan_subject  = "organization:${var.hcp_organization}:project:${var.hcp_project}:workspace:${var.hcp_workspace}:run_phase:plan"
  apply_subject = "organization:${var.hcp_organization}:project:${var.hcp_project}:workspace:${var.hcp_workspace}:run_phase:apply"

  common_tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
    Purpose   = "HCP Terraform dynamic credentials"
  }
}

resource "tfe_organization" "lab" {
  name  = var.hcp_organization
  email = var.admin_email
}

resource "tfe_project" "lab" {
  organization = tfe_organization.lab.name
  name         = var.hcp_project
}

resource "tfe_workspace" "aws_lab" {
  name              = var.hcp_workspace
  organization      = tfe_organization.lab.name
  project_id        = tfe_project.lab.id
  auto_apply        = false
  terraform_version = "1.16.1"

  description = "AWS networking lab managed with Terraform. Runs, state and resources are visible in HCP Terraform."
}

resource "aws_iam_openid_connect_provider" "hcp" {
  url = "https://${local.hcp_hostname}"

  client_id_list = [
    local.audience
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-hcp-oidc"
  })
}

data "aws_iam_policy_document" "hcp_plan_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.hcp.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.hcp_hostname}:aud"
      values   = [local.audience]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.hcp_hostname}:sub"
      values   = [local.plan_subject]
    }
  }
}

resource "aws_iam_role" "hcp_plan" {
  name               = "${var.project_name}-hcp-plan"
  assume_role_policy = data.aws_iam_policy_document.hcp_plan_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-hcp-plan"
  })
}

data "aws_iam_policy_document" "hcp_plan" {
  statement {
    sid       = "TerraformPlanReadAWS"
    effect    = "Allow"
    actions   = ["ec2:Describe*", "sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "hcp_plan" {
  name   = "${var.project_name}-hcp-plan-policy"
  role   = aws_iam_role.hcp_plan.id
  policy = data.aws_iam_policy_document.hcp_plan.json
}

data "aws_iam_policy_document" "hcp_apply_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.hcp.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.hcp_hostname}:aud"
      values   = [local.audience]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.hcp_hostname}:sub"
      values   = [local.apply_subject]
    }
  }
}

resource "aws_iam_role" "hcp_apply" {
  name               = "${var.project_name}-hcp-apply"
  assume_role_policy = data.aws_iam_policy_document.hcp_apply_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-hcp-apply"
  })
}

data "aws_iam_policy_document" "hcp_apply" {
  statement {
    sid    = "TerraformNetworkManagement"
    effect = "Allow"

    actions = [
      "ec2:AssociateRouteTable",
      "ec2:AttachInternetGateway",
      "ec2:CreateInternetGateway",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSubnet",
      "ec2:DeleteTags",
      "ec2:DeleteVpc",
      "ec2:Describe*",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateRouteTable",
      "ec2:ModifySubnetAttribute",
      "ec2:ModifyVpcAttribute",
      "ec2:ReplaceRouteTableAssociation",
      "sts:GetCallerIdentity"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "hcp_apply" {
  name   = "${var.project_name}-hcp-apply-policy"
  role   = aws_iam_role.hcp_apply.id
  policy = data.aws_iam_policy_document.hcp_apply.json
}

resource "tfe_variable" "aws_provider_auth" {
  workspace_id = tfe_workspace.aws_lab.id
  key          = "TFC_AWS_PROVIDER_AUTH"
  value        = "true"
  category     = "env"
  description  = "Enable HCP Terraform dynamic AWS credentials."
}

resource "tfe_variable" "aws_plan_role" {
  workspace_id = tfe_workspace.aws_lab.id
  key          = "TFC_AWS_PLAN_ROLE_ARN"
  value        = aws_iam_role.hcp_plan.arn
  category     = "env"
  description  = "AWS role used during Terraform plan."
}

resource "tfe_variable" "aws_apply_role" {
  workspace_id = tfe_workspace.aws_lab.id
  key          = "TFC_AWS_APPLY_ROLE_ARN"
  value        = aws_iam_role.hcp_apply.arn
  category     = "env"
  description  = "AWS role used during Terraform apply."
}

resource "tfe_variable" "aws_region" {
  workspace_id = tfe_workspace.aws_lab.id
  key          = "AWS_REGION"
  value        = var.aws_region
  category     = "env"
  description  = "AWS region used by the lab."
}
