#!/usr/bin/env bash
# scripts/local-produce-evidence.sh
# Run this from the repo root (~/cgep-labs) with Floci already running on :4566
set -euo pipefail

export AWS_ACCESS_KEY_ID=testgrc
export AWS_SECRET_ACCESS_KEY=testgrc1
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566

VAULT="cgep-lab-grc-evidence-vault-e53e936e"
RUN_ID="local-test-$(date +%s)"
SHA=$(git rev-parse HEAD)

echo "==> Using VAULT=${VAULT}  RUN_ID=${RUN_ID}  SHA=${SHA}"

echo "==> Generating terraform plan for evidence content"
mkdir -p evidence/lab-4-3
( cd terraform/primitives/compliant-s3 && \
  terraform init -input=false && \
  terraform plan -out=tfplan -input=false -no-color \
    -var="project_name=cgep-lab" -var="environment=dev" | tee plan.txt && \
  terraform show -json tfplan > plan.json )

cp terraform/primitives/compliant-s3/plan.json evidence/lab-4-3/plan.json
cp terraform/primitives/compliant-s3/plan.txt  evidence/lab-4-3/plan.txt

echo "==> Bundling, signing, uploading"
if command -v sha256sum >/dev/null 2>&1; then SHASUM="sha256sum"
elif command -v shasum >/dev/null 2>&1; then SHASUM="shasum -a 256"
else echo "Need sha256sum or shasum" >&2; exit 2; fi

BUNDLE="evidence-${RUN_ID}-${SHA}.tar.gz"
( cd evidence/lab-4-3 && tar czf "../../${BUNDLE}" . )
$SHASUM "${BUNDLE}" | awk '{print $1}' > "${BUNDLE}.sha256"

cosign sign-blob --yes --bundle "${BUNDLE}.sig.bundle" "${BUNDLE}"

KEY_PREFIX="runs/${RUN_ID}"
aws s3 cp "${BUNDLE}"            "s3://${VAULT}/${KEY_PREFIX}/${BUNDLE}"
aws s3 cp "${BUNDLE}.sha256"     "s3://${VAULT}/${KEY_PREFIX}/${BUNDLE}.sha256"
aws s3 cp "${BUNDLE}.sig.bundle" "s3://${VAULT}/${KEY_PREFIX}/${BUNDLE}.sig.bundle"

VERSION_ID=$(aws s3api head-object --bucket "${VAULT}" --key "${KEY_PREFIX}/${BUNDLE}" --query VersionId --output text)
cat > receipt.json <<EOF
{
  "run_id":"${RUN_ID}",
  "vault":"${VAULT}",
  "bundle_key":"${KEY_PREFIX}/${BUNDLE}",
  "version_id":"${VERSION_ID}",
  "sha256":"$(cat ${BUNDLE}.sha256)",
  "commit":"${SHA}"
}
EOF
aws s3 cp receipt.json "s3://${VAULT}/${KEY_PREFIX}/receipt.json"
mkdir -p evidence/lab-4-4
cp receipt.json evidence/lab-4-4/receipt.json

echo ""
echo "==> Done. To verify, run:"
echo "EVIDENCE_VAULT=\"${VAULT}\" bash scripts/verify-evidence.sh \"${RUN_ID}\" --vault \"${VAULT}\""
