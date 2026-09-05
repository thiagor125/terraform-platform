# Terraform Platform Bootstrap

This directory contains the infrastructure that supports Terraform itself rather than the application or lab resources Terraform manages.

It is intentionally separated from `environments/` so the control plane can stay available even when a lab environment is destroyed.

## What lives here

- HCP Terraform organization, project and workspace bootstrap code
- HCP-to-AWS OIDC trust
- IAM roles used for Terraform plan and apply phases
- historical AWS bootstrap components used while the platform was being established

## Normal operation

Day-to-day infrastructure work does **not** happen from this directory.

Normal changes follow this path:

```text
GitHub
→ HCP Terraform workspace
→ Plan
→ Review
→ Confirm & Apply
→ AWS
```

The code here should only be changed when the Terraform platform itself needs to change, for example when adding a new workspace, changing identity federation, or extending the platform to another cloud.

Keeping the bootstrap layer separate from deployable environments is what allows an environment such as `aws-lab` to be destroyed and rebuilt without removing the control plane needed to manage it.
