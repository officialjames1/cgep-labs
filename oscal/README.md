# OSCAL Compliance Artifacts

This directory contains the OSCAL-formatted compliance documentation for the CGE-P project's Terraform primitives, authored and validated with [compliance-trestle](https://github.com/oscal-compliance/compliance-trestle).

## Contents

### `components/compliant-s3.json`

Describes the `compliant-s3` Terraform module (`terraform/primitives/compliant-s3`) — a reusable pattern for an S3 primary bucket plus a dedicated access-log bucket. Documents four implemented NIST 800-53 Rev 5 controls:

| Control | Requirement | Enforced by |
|---|---|---|
| `sc-28` | Protection of Information at Rest | `aws_s3_bucket_server_side_encryption_configuration.primary` (SSE-KMS, customer-managed key via `aws_kms_key.s3`) |
| `ac-3` | Access Enforcement | `aws_s3_bucket_public_access_block.primary` |
| `au-3` | Content of Audit Records | `aws_s3_bucket_logging.primary` |
| `cm-6` | Configuration Settings | `aws_s3_bucket_versioning.primary` |

Each requirement links to the same signed evidence bundle (see below), pulled from an actual CI-produced `terraform plan` of the module.

### `profiles/cge-p-minimum.json`

The CGE-P minimum control selection — a trestle profile that imports the four controls above from the NIST SP 800-53 Rev 5 catalog. Resolving this profile (`trestle author profile-resolve`) produces the full control text for `sc-28`, `ac-3`, `au-3`, and `cm-6` as a self-contained catalog.

## Where the evidence lives

Every `links[rel=evidence]` entry in `components/compliant-s3.json` points to a signed evidence bundle in the project's S3 evidence vault:


This bundle was produced and signed by the `grc-gate` GitHub Actions workflow (`.github/workflows/grc-gate.yml`, run [33811511395](https://github.com/officialjames1/cgep-labs/actions/runs/33811511395)) — not a local/manual run. Its Sigstore signature is bound to that CI workflow's identity, which is what `scripts/verify-evidence.sh` checks for. Locally-produced bundles (e.g. via `scripts/local-produce-evidence.sh`) are signed with a personal identity and will **not** pass verification against this pipeline's expected certificate identity.

To independently verify the chain of custody for this evidence (from inside the repo, with Floci running on `localhost:4566` if verifying against a local vault, or against the real CI-produced bucket otherwise):

```bash
export AWS_ENDPOINT_URL=http://localhost:4566   # if applicable
EVIDENCE_VAULT="cgep-lab-grc-evidence-vault-e53e936e" \
  bash scripts/verify-evidence.sh "33811511395" --vault "cgep-lab-grc-evidence-vault-e53e936e"
```

A successful run prints `CHAIN INTACT for run 33811511395`, confirming the artifact is authentic and unaltered since it was signed.

## Authoring workflow

These files are authored inside a git-ignored `.trestle-work/` scratch directory (trestle's native OSCAL layout) and copied into this flatter `oscal/` structure once validated:

```bash
python3 -m trestle validate -f component-definitions/compliant-s3-v1/component-definition.json
python3 -m trestle validate -f profiles/cge-p-minimum/profile.json
```

Do not hand-edit files in this directory directly if `.trestle-work/` still exists — edit the source in `.trestle-work/`, validate, then re-copy, so the two stay in sync.