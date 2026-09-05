# Azure adoption plan

This lab uses AWS to validate the Terraform operating model. An Azure rollout should start with discovery and governance rather than copying the AWS resources directly.

## 1. Discovery

- Inventory subscriptions, management groups, regions and existing resources.
- Identify resource ownership, criticality and regulatory requirements.
- Define naming, tagging, network and access standards with the platform and security teams.
- Decide which existing resources will be imported and which will remain outside Terraform.

## 2. Platform foundation

- Keep Terraform code in GitHub and use pull requests for review.
- Use HCP Terraform for remote runs, state, locking and run history.
- Authenticate through workload identity federation with Microsoft Entra ID.
- Separate plan and apply permissions and follow least privilege.
- Create independent workspaces for development, homologation and production.

## 3. First reusable modules

Start with a small set of well-defined modules:

- Resource groups and mandatory tags
- Virtual networks and subnets
- Network security groups
- Private DNS and private endpoints
- Key Vault access and diagnostics
- Log Analytics and Azure Monitor configuration

Each module should have typed inputs, validation, documented outputs and automated checks.

## 4. Safe migration

- Start with a non-production pilot.
- Import existing resources gradually instead of rebuilding the environment at once.
- Review every plan and prevent unexpected replacement or destruction.
- Validate monitoring, backup and rollback before expanding the scope.
- Record architecture decisions and operational responsibilities.

## 5. Scale and governance

- Apply policy as code and security checks in CI.
- Detect configuration drift and review provider updates regularly.
- Publish versioned modules for application teams.
- Track deployment lead time, failed changes and recovery time.
- Expand only after the pilot has clear ownership and operating procedures.

The goal is not only to deploy Azure resources with Terraform. It is to create a secure and repeatable way for teams to propose, review and operate infrastructure changes.
