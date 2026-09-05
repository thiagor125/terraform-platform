# Architecture

The repository is intentionally organized as a monorepo so the complete Terraform flow can be followed in one place.

```text
terraform-platform/
│
├── platform/             bootstrap, identity and HCP Terraform
├── modules/              reusable infrastructure code
├── environments/         deployable environments
├── scripts/              lifecycle helpers
└── .github/workflows/    automation
```

## Control plane

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
OIDC / Dynamic AWS Credentials
    │
    ▼
AWS
```

GitHub is the source-control and collaboration layer. HCP Terraform is the Terraform execution and state control layer. AWS receives short-lived credentials from HCP Terraform through workload identity federation instead of long-lived AWS keys.

## AWS lab

The AWS environment uses the HCP Terraform workspace `thiagor125/aws-lab` as its permanent backend.

The lab workspace manages networking resources only:

- VPC
- public and private subnets
- Internet Gateway
- public and private route tables
- route table associations
- public Internet route

The HCP bootstrap resources are intentionally separated from the lab workspace. This lets the network be destroyed to reduce lab cost without removing the identity path needed to rebuild it.

## Lifecycle

```text
Git change
    ↓
Remote plan in HCP Terraform
    ↓
Review
    ↓
Explicit approval
    ↓
Remote apply/destroy in HCP Terraform
    ↓
Remote state update
    ↓
Verification plan
```

Destroying the AWS lab removes only resources tracked by the `aws-lab` state. Rebuilding runs the same Terraform configuration against the empty workspace state and recreates those resources.

## Module versioning

Deployable environments reference reusable modules through immutable Git commit references. This prevents a change to the repository default branch from silently changing the module code used by an environment.

## Future Azure mapping

The same architecture will be extended to Azure:

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
