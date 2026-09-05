resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name = "${var.project_name}-github-oidc"
  }
}

#
# PLAN ROLE
#

data "aws_iam_policy_document" "github_plan_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        local.github_plan_subject
      ]
    }
  }
}

resource "aws_iam_role" "terraform_plan" {
  name = "${var.project_name}-github-plan"

  assume_role_policy = data.aws_iam_policy_document.github_plan_assume_role.json

  max_session_duration = 3600

  tags = {
    Name = "${var.project_name}-github-plan"
  }
}

#
# PLAN ROLE PERMISSIONS
#

data "aws_iam_policy_document" "terraform_plan" {
  statement {
    sid = "TerraformStateBucket"

    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      data.aws_s3_bucket.terraform_state.arn
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "environments/lab/*"
      ]
    }
  }

  statement {
    sid = "TerraformStateRead"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]

    resources = [
      "${data.aws_s3_bucket.terraform_state.arn}/environments/lab/terraform.tfstate"
    ]
  }

  statement {
    sid = "TerraformStateLock"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${data.aws_s3_bucket.terraform_state.arn}/environments/lab/terraform.tfstate.tflock"
    ]
  }

  statement {
    sid = "TerraformPlanReadAWS"

    effect = "Allow"

    actions = [
      "ec2:Describe*",
      "sts:GetCallerIdentity"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "terraform_plan" {
  name = "${var.project_name}-plan-policy"
  role = aws_iam_role.terraform_plan.id

  policy = data.aws_iam_policy_document.terraform_plan.json
}

#
# APPLY ROLE
#

data "aws_iam_policy_document" "github_apply_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        local.github_apply_subject
      ]
    }
  }
}

resource "aws_iam_role" "terraform_apply" {
  name = "${var.project_name}-github-apply"

  assume_role_policy = data.aws_iam_policy_document.github_apply_assume_role.json

  max_session_duration = 3600

  tags = {
    Name = "${var.project_name}-github-apply"
  }
}

#
# APPLY ROLE PERMISSIONS
#

data "aws_iam_policy_document" "terraform_apply" {
  statement {
    sid = "TerraformStateBucket"

    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      data.aws_s3_bucket.terraform_state.arn
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "environments/lab/*"
      ]
    }
  }

  statement {
    sid = "TerraformState"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]

    resources = [
      "${data.aws_s3_bucket.terraform_state.arn}/environments/lab/terraform.tfstate"
    ]
  }

  statement {
    sid = "TerraformStateLock"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${data.aws_s3_bucket.terraform_state.arn}/environments/lab/terraform.tfstate.tflock"
    ]
  }

  statement {
    sid = "TerraformNetworkManagement"

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

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "terraform_apply" {
  name = "${var.project_name}-apply-policy"
  role = aws_iam_role.terraform_apply.id

  policy = data.aws_iam_policy_document.terraform_apply.json
}
