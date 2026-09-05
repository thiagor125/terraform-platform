# Terraform Lab

This is my hands-on Terraform lab. I use it to study how infrastructure code, reusable modules, CI/CD, identity federation and remote state fit together in a real workflow.

Everything lives in one repository so the architecture is easier to understand and operate.

## Repository layout

```text
terraform-lab/
├── platform/                 # bootstrap, identity and HCP Terraform setup
├── modules/                  # reusable Terraform modules
├── environments/             # deployable AWS and Azure environments
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
- remote Terraform state in S3
- OIDC-based authentication for automation

The AWS environment is under `environments/aws/lab` and consumes the reusable network module from `modules/aws/network`.

## Where this is going

The next step is HCP Terraform Free so runs, plans, applies, state and managed resources can be viewed from a Terraform console instead of only through CI logs. After that, the same structure will be extended to Azure.

This is a learning and architecture lab, not a finished production platform.
