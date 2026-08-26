# sc_28 encryption.rego
# SC-28, encryption at rest
#   severity: high
#   remediation: "Add an encryption { default_kms_key_name = ... } block referencing a google_kms_crypto_key you control."
# Lab 3-4 (AWS)


# ac3_no_public.rego
# AC-3 - Access Enforcement (no public GCS or open firewall)
#   severity: critical
#   remediation: "Set uniform_bucket_level_access = true, public_access_prevention = enforced. For firewalls, narrow source_ranges or remove the rule."
# Lab 3-4 (AWS)


# cm6_required_tags.rego
# CM-6 - Configuration Settings (required compliance labels)
#   severity: medium
#   remediation: "Add the four required labels (project, environment, managed_by, compliance_scope) to the resource."
# Lab 3-4 (AWS Version w/Tags)
