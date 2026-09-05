# Terraform Lab

This is my hands-on Terraform lab for learning enterprise-style infrastructure workflows with reusable modules, remote execution, remote state, identity federation and controlled lifecycle operations.

Everything lives in one repository so the architecture is easier to understand, audit and operate.

## Repository layout

```text
terraform-platform/
├── platform/                 # bootstrap, identity and HCP Terraform setup
├── modules/                  # reusable Terraform modules
├── environments/             # deployable AWS and Azure environments
├── scripts/                  # lifecycle and migration helpers
├── docs/                     # architecture notes
└── .github/workflows/        # CI/CD and HCP remote execution
```

## Current architecture

```text
Developer
    │
    ▼
GitHub
    │
    ▼
HCP Terraform
├── Remote Runs
├── Remote State
├── Plan
├── Apply
└── Audit
    │
    ▼
OIDC / Dynamic Credentials
    │
    ▼
AWS
```

The AWS lab uses the HCP Terraform workspace `thiagor125/aws-lab` as its permanent backend and execution layer.

## What is running today

The AWS lab manages a small network in `us-east-1`:

- one VPC
- two public subnets
- two private subnets
- one Internet Gateway
- public and private route tables
- route table associations
- HCP Terraform dynamic AWS credentials through OIDC

The environment is under `environments/aws/lab` and consumes the reusable network module from `modules/aws/network` using an immutable Git commit reference.

## GitHub to HCP Terraform

Pull requests can run a speculative remote plan through:

```text
.github/workflows/aws-lab-hcp-plan.yml
```

Manual applies can run through:

```text
.github/workflows/aws-lab-hcp-apply.yml
```

The GitHub runner does not need AWS credentials for these workflows. It authenticates to HCP Terraform, and HCP Terraform obtains short-lived AWS credentials through OIDC for the remote run.

The GitHub repository requires the secret:

```text
HCP_TERRAFORM_TOKEN
```

Do not commit HCP tokens to the repository.

## AWS lab lifecycle

The lab can be intentionally destroyed when it is not being used, while keeping the HCP/OIDC control plane available so Terraform can rebuild it later.

First export a valid HCP Terraform token as `TF_TOKEN_app_terraform_io`.

Preview the current configuration:

```bash
make aws-plan
```

Destroy the managed AWS lab resources:

```bash
make aws-destroy
```

The destroy helper always runs a destroy plan first and requires the exact confirmation phrase:

```text
DESTROY-AWS-LAB
```

Recreate the AWS lab from the Terraform code:

```bash
make aws-rebuild
```

The rebuild helper runs a plan first and requires:

```text
REBUILD-AWS-LAB
```

After rebuild, it runs another plan to verify convergence.

The destroy lifecycle targets only the resources managed by the `aws-lab` workspace. HCP Terraform, its workspace, the HCP-to-AWS OIDC provider and the IAM roles used for dynamic credentials are intentionally kept outside that workspace so the lab remains rebuildable.

## Safety model

Infrastructure changes follow this sequence:

```text
Current state
    ↓
Terraform plan
    ↓
Review add/change/destroy
    ↓
Explicit approval
    ↓
Terraform apply/destroy
    ↓
Verification plan
```

Destructive HCP bootstrap plans are blocked by `scripts/hcp-bootstrap-and-migrate.sh`.

## Next

The next expansion is Azure using the same control-plane pattern: GitHub, HCP Terraform, workload identity federation, remote state, controlled plans/applies and separated environments.

This is a learning and architecture lab, not a finished production platform.
