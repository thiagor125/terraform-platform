# Terraform Platform

This repository is the shared execution layer for my Terraform lab.

I built it to keep `plan` and `apply` in one place instead of relying on Terraform and cloud credentials installed on every engineer's workstation. GitHub Actions starts a temporary runner, installs Terraform, authenticates to the cloud through OIDC, reads the remote state, and runs the workflow from there.

## What lives here

- reusable Terraform plan and apply workflows
- AWS bootstrap for remote state and GitHub OIDC
- shared execution standards for the lab

## How it fits together

`terraform-live` describes the environment, `terraform-modules` provides reusable building blocks, and this repository handles the execution path.

```text
Pull Request
    ↓
terraform-live
    ↓
shared workflow in terraform-platform
    ↓
GitHub Actions runner
    ↓
OIDC
    ↓
AWS
```

The current implementation uses AWS as a hands-on lab. The same execution model will be extended to Azure with Microsoft Entra workload identity federation and Azure remote state.

> This is a learning and architecture lab, not a production platform offered as a finished product.
