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

if [[ -z "${TF_TOKEN_app_terraform_io:-}" && -z "${TFE_TOKEN:-}" ]]; then
  echo
  echo "HCP Terraform API token is required."
  echo "Create a NEW user token in HCP Terraform, then paste it below."
  echo "The token will not be echoed or stored in the repository."
  read -rsp "HCP Terraform token: " HCP_TOKEN
  echo

  if [[ -z "$HCP_TOKEN" ]]; then
    echo "Token is required."
    exit 1
  fi

  export TF_TOKEN_app_terraform_io="$HCP_TOKEN"
  export TFE_TOKEN="$HCP_TOKEN"
  unset HCP_TOKEN
elif [[ -n "${TF_TOKEN_app_terraform_io:-}" && -z "${TFE_TOKEN:-}" ]]; then
  export TFE_TOKEN="$TF_TOKEN_app_terraform_io"
elif [[ -n "${TFE_TOKEN:-}" && -z "${TF_TOKEN_app_terraform_io:-}" ]]; then
  export TF_TOKEN_app_terraform_io="$TFE_TOKEN"
fi

ACCOUNT_ID="$(aws sts get-caller-identity --profile "$AWS_PROFILE" --query Account --output text)"
STATE_BUCKET="${PROJECT_NAME}-${ACCOUNT_ID}-${AWS_REGION}-tfstate"

echo
printf 'HCP organization : %s\n' "$HCP_ORGANIZATION"
printf 'HCP project      : %s\n' "$HCP_PROJECT"
printf 'HCP workspace    : %s\n' "$HCP_WORKSPACE"
printf 'AWS account      : %s\n' "$ACCOUNT_ID"
printf 'AWS region       : %s\n' "$AWS_REGION"
printf 'AWS profile      : %s\n' "$AWS_PROFILE"
printf 'State bucket     : %s\n' "$STATE_BUCKET"
echo

TMP_TFVARS="$(mktemp)"
TMP_S3_BACKEND="$(mktemp)"
TMP_HCP_BACKEND="$(mktemp)"
cleanup() {
  rm -f "$TMP_TFVARS" "$TMP_S3_BACKEND" "$TMP_HCP_BACKEND"
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

cat > "$TMP_S3_BACKEND" <<EOF
terraform {
  backend "s3" {}
}
EOF

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

# Bootstrap HCP/AWS integration. This is idempotent after the first successful apply.
pushd "$HCP_BOOTSTRAP_DIR" >/dev/null
terraform init -reconfigure \
  -backend-config="bucket=$STATE_BUCKET" \
  -backend-config="key=bootstrap/hcp/terraform.tfstate" \
  -backend-config="region=$AWS_REGION" \
  -backend-config="profile=$AWS_PROFILE" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

terraform plan -var-file="$TMP_TFVARS" -out=tfplan
terraform apply tfplan
popd >/dev/null

pushd "$AWS_ENV_DIR" >/dev/null

# A previous interrupted migration may have left backend.tf pointing at HCP locally.
# Force it back to S3 first so Terraform can read and verify the existing state.
cp "$TMP_S3_BACKEND" backend.tf
terraform init -reconfigure \
  -backend-config="bucket=$STATE_BUCKET" \
  -backend-config="key=environments/lab/terraform.tfstate" \
  -backend-config="region=$AWS_REGION" \
  -backend-config="profile=$AWS_PROFILE" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

echo
STATE_COUNT="$(terraform state list | wc -l | tr -d ' ')"
echo "Existing S3 state resources: $STATE_COUNT"
if [[ "$STATE_COUNT" -eq 0 ]]; then
  echo "Refusing migration because the existing S3 state is empty."
  exit 1
fi

# Now change only the backend and let Terraform copy the existing state to HCP.
cp "$TMP_HCP_BACKEND" backend.tf
set +e
terraform init -migrate-state -force-copy
MIGRATE_RC=$?
set -e

if [[ $MIGRATE_RC -ne 0 ]]; then
  echo "State migration failed. Restoring the S3 backend locally."
  cp "$TMP_S3_BACKEND" backend.tf
  terraform init -reconfigure \
    -backend-config="bucket=$STATE_BUCKET" \
    -backend-config="key=environments/lab/terraform.tfstate" \
    -backend-config="region=$AWS_REGION" \
    -backend-config="profile=$AWS_PROFILE" \
    -backend-config="encrypt=true" \
    -backend-config="use_lockfile=true" || true
  exit $MIGRATE_RC
fi

echo
HCP_STATE_COUNT="$(terraform state list | wc -l | tr -d ' ')"
echo "HCP state resources after migration: $HCP_STATE_COUNT"
if [[ "$HCP_STATE_COUNT" -ne "$STATE_COUNT" ]]; then
  echo "State count mismatch after migration. Stop here and review before any apply."
  exit 1
fi

# Plan only. No infrastructure apply is executed here.
terraform plan
popd >/dev/null

echo
echo "HCP Terraform is now the backend for the AWS lab."
echo "Open: https://app.terraform.io/app/$HCP_ORGANIZATION/workspaces/$HCP_WORKSPACE"
echo "No AWS lab apply was executed by this migration step."
