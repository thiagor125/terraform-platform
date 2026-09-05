#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$ROOT_DIR/environments/aws/lab"

command -v terraform >/dev/null 2>&1 || { echo "Terraform is required."; exit 1; }

if [[ -z "${TF_TOKEN_app_terraform_io:-}" ]]; then
  echo "HCP Terraform token is required in TF_TOKEN_app_terraform_io."
  exit 1
fi

echo "AWS lab destroy - PLAN ONLY first"
echo "Workspace: thiagor125 / aws-lab"
echo

terraform -chdir="$ENV_DIR" init -reconfigure
terraform -chdir="$ENV_DIR" plan -destroy

echo
read -rp "Type DESTROY-AWS-LAB to continue: " CONFIRM
if [[ "$CONFIRM" != "DESTROY-AWS-LAB" ]]; then
  echo "Destroy cancelled."
  exit 0
fi

echo
terraform -chdir="$ENV_DIR" destroy -auto-approve

echo
COUNT="$(terraform -chdir="$ENV_DIR" state list 2>/dev/null | wc -l | tr -d ' ')"
echo "AWS lab resources remaining in HCP state: $COUNT"
