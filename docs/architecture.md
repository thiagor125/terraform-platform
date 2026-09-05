# Architecture

This repository keeps the Terraform platform, reusable modules and deployable environments in one place so the full infrastructure flow is easy to follow.

```text
terraform-platform/
│
├── platform/             bootstrap and identity for the Terraform platform
├── modules/              reusable infrastructure code
├── environments/         deployable environments
├── docs/                 architecture and operating notes
└── .github/workflows/    CI checks only
```

## Control plane

```text
Developer
    │
    ▼
GitHub
    │
    │ VCS integration
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
OIDC / dynamic AWS credentials
    │
    ▼
AWS
```

GitHub stores and reviews the Terraform code. HCP Terraform executes infrastructure runs, keeps the remote state and records the run history. AWS trusts HCP Terraform through workload identity federation, so the workspace can use short-lived credentials instead of static AWS keys.

## AWS lab

The current environment is the HCP Terraform workspace `aws-lab`.

Its working directory is:

```text
environments/aws/lab
```

It manages only the lab networking layer:

- VPC
- public and private subnets
- Internet Gateway
- public and private route tables
- route table associations
- public Internet route

The HCP-to-AWS identity resources are intentionally outside the `aws-lab` state. This allows the lab network to be destroyed without removing the credentials HCP needs to rebuild it.

## Change flow

```text
Terraform code change
    ↓
Push or pull request in GitHub
    ↓
HCP Terraform VCS run
    ↓
Plan
    ↓
Human review
    ↓
Confirm & Apply
    ↓
AWS
```

Auto apply is disabled. A successful plan does not change AWS until someone explicitly approves the run in HCP Terraform.

GitHub Actions is used only for non-destructive CI checks such as formatting and validation.

## Lab lifecycle

The lab can be removed and recreated from the HCP Terraform UI.

Destroy path:

```text
Workspaces
→ aws-lab
→ Settings
→ Destruction and deletion
→ Queue destroy plan
```

Rebuild path:

```text
Workspaces
→ aws-lab
→ New run
→ Start run
→ Confirm & Apply
```

Before a destroy or rebuild, always review the resource counts and the exact addresses Terraform plans to change.

## Module versioning

Deployable environments reference reusable modules through immutable Git commit references. This prevents a future change to `main` from silently replacing the module code used by an existing environment.

## Future Azure mapping

The same control-plane model can be extended to Azure:

```text
GitHub
    │
    ▼
HCP Terraform
    │
    ▼
Workload Identity Federation
    │
    ▼
Microsoft Entra ID / Azure RBAC
    │
    ▼
Azure subscriptions and resources
```

The intended next stage is to introduce separate Azure workspaces for development, homologation and production while keeping the same approval and audit model.
