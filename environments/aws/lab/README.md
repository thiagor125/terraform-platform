# AWS Lab

This directory is the Terraform configuration used by the HCP Terraform workspace `aws-lab`.

The workspace is connected directly to GitHub through VCS integration, so changes pushed to this directory generate a Terraform run in HCP Terraform automatically.

## What this workspace manages

- VPC `10.10.0.0/16`
- 2 public subnets
- 2 private subnets
- Internet Gateway
- public and private route tables
- route table associations
- public route to the Internet

The network module is consumed from `modules/aws/network` using an immutable Git commit reference.

## How changes are applied

```text
Change code here
    ↓
Push to GitHub
    ↓
HCP Terraform creates a run
    ↓
Review the plan
    ↓
Confirm & Apply
```

Auto apply is disabled on purpose. A plan can complete successfully without changing AWS until someone approves it in the HCP Terraform UI.

## Destroy the lab

Use the HCP Terraform interface:

```text
aws-lab
→ Settings
→ Destruction and deletion
→ Queue destroy plan
```

Before confirming, verify that the destroy plan contains only the resources that belong to this lab.

## Rebuild the lab

Once the workspace has no managed AWS resources, start a normal run:

```text
aws-lab
→ New run
→ Start run
```

Terraform will compare this configuration with the empty state and propose recreating the lab. Review the plan, then use `Confirm & Apply`.

The AWS identity resources used by HCP Terraform are managed separately, so destroying this workspace does not remove the path needed to rebuild it.
