# Terraform Lab

This is my hands-on Terraform lab. I use it to study how infrastructure code, reusable modules, CI/CD, identity federation and remote state fit together in a real workflow.

Everything lives in one repository so the architecture is easier to understand and operate.

## Repository layout

```text
terraform-lab/
├── platform/                 # bootstrap, identity and HCP Terraform setup
├── modules/                  # reusable Terraform modules
├── environments/             # deployable AWS and Azure environments
├── scripts/                  # bootstrap and migration helpers
├── docs/                     # architecture notes
└── .github/workflows/        # shared CI/CD workflows
```

## What is running today

The current AWS lab manages a small network in `us-east-1`:

- one VPC
- two public subnets
- two private subnets
- one Internet Gateway
- public and private route tables
- OIDC-based authentication for automation

The AWS environment is under `environments/aws/lab` and consumes the reusable network module from `modules/aws/network`.

## HCP Terraform Free

The repository is prepared to move the AWS lab state into HCP Terraform Free so runs, plans, applies, state and managed resources can be inspected from the Terraform console.

The bootstrap script creates the HCP organization, project and `aws-lab` workspace, creates AWS IAM roles for HCP dynamic credentials, migrates the existing S3 state into HCP Terraform, and then runs a remote plan.

```bash
bash scripts/hcp-bootstrap-and-migrate.sh
```

The script requires an interactive `terraform login app.terraform.io` the first time. No HCP token should be committed to this repository.

## Lab lifecycle

The AWS network can be intentionally removed and recreated through Terraform by changing `deploy_network`.

```bash
terraform -chdir=environments/aws/lab apply -var='deploy_network=false'
terraform -chdir=environments/aws/lab apply -var='deploy_network=true'
```

Once the state migration is complete, these operations run against the HCP Terraform workspace instead of a local state file.

## Next

After HCP Terraform is validated, the same repository structure will be extended to Azure.

This is a learning and architecture lab, not a finished production platform.
