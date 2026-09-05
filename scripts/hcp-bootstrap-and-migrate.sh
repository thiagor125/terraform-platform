#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HCP_BOOTSTRAP_DIR="$ROOT_DIR/platform/hcp"
AWS_ENV_DIR="$ROOT_DIR/environments/aws/lab"
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_PROFILE="${AWS_PROFILE:-terraform-lab}"
PROJECT_NAME="${PROJECT_NAME:-terraform-enterprise-lab}"
HCP_PROJECT="${HCP_PROJECT:-terraform-lab}"
HCP_WORKSPACE="${HCP_WORKSPACE:-aws-lab}"

command -v terraform >/dev/null 2>&1 || { echo "Terraform is required."; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "AWS CLI is required."; exit 1; }

if [[ -z "${HCP_ORGANIZATION:-}" ]]; then
  read -rp "HCP Terraform organization name: " HCP_ORGANIZATION
fi

if [[ -z "${HCP_ADMIN_EMAIL:-}" ]]; then
  read -rp "Email for the HCP Terraform organization: " HCP_ADMIN_EMAIL
fi

if [[ -z "$HCP_ORGANIZATION" || -z "$HCP_ADMIN_EMAIL" ]]; then
  echo "Organization name and email are required."
  exit 1
fi

ACCOUNT_ID="$(aws sts get-caller-identity --profile "$AWS_PROFILE" --query Account --output text)"
STATE_BUCKET="${PROJECT_NAME}-${ACCOUNT_ID}-${AWS_REGION}-tfstate"

echo
printf 'HCP organization : %s\n' "$HCP_ORGANIZATION"
printf 'HCP project      : %s\n' "$HCP_PROJECT"
printf 'HCP workspace    : %s\n' "$HCP_WORKSPACE"
printf 'AWS account      : %s\n' "$ACCOUNT_ID"
printf 'AWS region       : %s\n' "$AWS_REGION"
printf 'State bucket     : %s\n' "$STATE_BUCKET"
echo

if [[ ! -f "$HOME/.terraform.d/credentials.tfrc.json" ]]; then
  echo "HCP Terraform authentication is required."
  terraform login app.terraform.io
fi

TMP_TFVARS="$(mktemp)"
TMP_HCP_BACKEND="$(mktemp)"
cleanup() {
  rm -f "$TMP_TFVARS" "$TMP_HCP_BACKEND"
}
trap cleanup EXIT

cat > "$TMP_TFVARS" <<EOF
hcp_organization = "$HCP_ORGANIZATION"
hcp_project      = "$HCP_PROJECT"
hcp_workspace    = "$HCP_WORKSPACE"
admin_email      = "$HCP_ADMIN_EMAIL"
project_name     = "$PROJECT_NAME"
aws_region       = "$AWS_REGION"
aws_profile      = "$AWS_PROFILE"
EOF

pushd "$HCP_BOOTSTRAP_DIR" >/dev/null
terraform init -reconfigure \
  -backend-config="bucket=$STATE_BUCKET" \
  -backend-config="key=bootstrap/hcp/terraform.tfstate" \
  -backend-config="region=$AWS_REGION" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

terraform plan -var-file="$TMP_TFVARS" -out=tfplan
terraform apply tfplan
popd >/dev/null

cat > "$TMP_HCP_BACKEND" <<EOF
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "$HCP_ORGANIZATION"

    workspaces {
      name = "$HCP_WORKSPACE"
    }
  }
}
EOF

pushd "$AWS_ENV_DIR" >/dev/null
cp backend.tf backend.tf.s3-backup
cp "$TMP_HCP_BACKEND" backend.tf

set +e
terraform init -migrate-state -force-copy
MIGRATE_RC=$?
set -e

if [[ $MIGRATE_RC -ne 0 ]]; then
  echo "State migration failed. Restoring the S3 backend file."
  mv backend.tf.s3-backup backend.tf
  terraform init -reconfigure \
    -backend-config="bucket=$STATE_BUCKET" \
    -backend-config="key=environments/lab/terraform.tfstate" \
    -backend-config="region=$AWS_REGION" \
    -backend-config="encrypt=true" \
    -backend-config="use_lockfile=true" || true
  exit $MIGRATE_RC
fi

rm -f backend.tf.s3-backup
terraform plan
popd >/dev/null

echo
echo "HCP Terraform is now the backend for the AWS lab."
echo "Open: https://app.terraform.io/app/$HCP_ORGANIZATION/workspaces/$HCP_WORKSPACE"
echo
echo "To destroy only the AWS lab network later:"
echo "  terraform -chdir=environments/aws/lab apply -var='deploy_network=false'"
echo
echo "To recreate it:"
echo "  terraform -chdir=environments/aws/lab apply -var='deploy_network=true'"
