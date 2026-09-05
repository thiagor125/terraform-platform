#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$ROOT_DIR/environments/aws/lab"

command -v terraform >/dev/null 2>&1 || { echo "Terraform is required."; exit 1; }

if [[ -z "${TF_TOKEN_app_terraform_io:-}" ]]; then
  echo "HCP Terraform token is required in TF_TOKEN_app_terraform_io."
  exit 1
fi

echo "AWS lab rebuild - PLAN ONLY first"
echo "Workspace: thiagor125 / aws-lab"
echo

terraform -chdir="$ENV_DIR" init -reconfigure
terraform -chdir="$ENV_DIR" plan

echo
read -rp "Type REBUILD-AWS-LAB to continue: " CONFIRM
if [[ "$CONFIRM" != "REBUILD-AWS-LAB" ]]; then
  echo "Rebuild cancelled."
  exit 0
fi

echo
terraform -chdir="$ENV_DIR" apply -auto-approve

echo
terraform -chdir="$ENV_DIR" plan
