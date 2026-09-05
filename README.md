# Terraform Platform Lab

A hands-on Terraform platform lab focused on the way infrastructure is operated in a real team: code in GitHub, remote runs and state in HCP Terraform, short-lived cloud credentials through OIDC, and explicit approval before infrastructure changes are applied.

The repository is intentionally small enough to understand end to end, but the structure is meant to scale to multiple environments and, later, Azure.

## How it works

```text
Developer
    │
    ▼
GitHub
    │
    │ push / pull request
    ▼
HCP Terraform
├── Runs
├── Plan
├── Apply
├── State
├── Resources
└── Run history
    │
    ▼
OIDC / dynamic credentials
    │
    ▼
AWS
```

GitHub is the source of truth for the Terraform code. HCP Terraform is the control plane for infrastructure execution and state. AWS receives temporary credentials from HCP Terraform instead of long-lived access keys.

## Repository structure

```text
terraform-platform/
├── platform/                 # bootstrap and identity used by the Terraform platform
├── modules/                  # reusable Terraform modules
├── environments/             # deployable environments
│   └── aws/lab/              # current AWS lab workspace
├── docs/                     # architecture and operating notes
└── .github/workflows/        # CI checks only
```

## Current AWS lab

The `aws-lab` HCP Terraform workspace currently manages a small network in `us-east-1`:

- 1 VPC
- 2 public subnets
- 2 private subnets
- 1 Internet Gateway
- public and private route tables
- route table associations
- public Internet route

The environment code lives in `environments/aws/lab` and consumes the reusable network module from `modules/aws/network` through an immutable Git commit reference.

## Day-to-day workflow

For normal changes, edit the Terraform code and push it to GitHub. HCP Terraform is connected directly to this repository and automatically creates a run when relevant files change.

```text
Code change
    ↓
GitHub
    ↓
HCP Terraform plan
    ↓
Review the proposed changes
    ↓
Confirm & Apply in the HCP UI
    ↓
AWS
```

Auto apply is intentionally disabled. Infrastructure changes require an explicit approval in HCP Terraform.

GitHub Actions is kept only for CI checks such as Terraform formatting and validation. It does not apply or destroy infrastructure.

## Destroying and rebuilding the lab

The lab is designed so the AWS resources managed by `aws-lab` can be removed when they are not needed and recreated later from the same Terraform code.

### Destroy

In HCP Terraform:

```text
Workspaces
→ aws-lab
→ Settings
→ Destruction and deletion
→ Queue destroy plan
```

Review the destroy plan carefully before confirming it. The expected lab destroy removes only resources tracked by the `aws-lab` workspace.

### Rebuild

After the workspace state is empty, keep the Terraform code in GitHub unchanged and start a normal run in HCP Terraform:

```text
Workspaces
→ aws-lab
→ New run
→ Start run
```

HCP Terraform should plan the resources again. Review the plan and use `Confirm & Apply` to recreate the lab.

The HCP workspace, AWS OIDC provider, and IAM roles used for HCP dynamic credentials are intentionally managed outside the `aws-lab` workspace. That keeps the control path available after the lab network itself is destroyed.

## Safety model

Before any infrastructure change, the intended flow is always:

```text
Current state
    ↓
Plan
    ↓
Review add / change / destroy
    ↓
Explicit approval
    ↓
Apply or destroy
    ↓
Verify the resulting state
```

## Next step

The next major expansion is Azure using the same operating model: GitHub for code, HCP Terraform for runs and state, workload identity federation for authentication, and separate workspaces for environments such as development, homologation and production.
