# Architecture

The repository is intentionally organized as a monorepo so the complete Terraform flow can be followed in one place.

```text
GitHub repository
│
├── platform/             bootstrap, identity and HCP Terraform
├── modules/              reusable infrastructure code
├── environments/         deployable environments
└── .github/workflows/    automation
```

Today the AWS lab still uses an S3 remote backend. HCP Terraform Free is the next control layer so runs, plans, applies, state and resources can be inspected from one console.

The AWS environment currently manages networking only, which keeps the lab inexpensive while still exercising the full Terraform lifecycle.
