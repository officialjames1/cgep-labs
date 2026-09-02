# Data Access Logs = DEFAULT = OFF
# On org_policy.tf there are three CTRLs in place that this work applies to. We will start with the first, AC-2 under iam.disableServiceAccountKeyCreation which is part of
# the policy that is in effect to safeguard external account keys from being created.
# AC-3 means that the compute.require0sLogin policy requires a login through Google Clouds platform
# Finally, CM-6 enforces unified access across IAM within the Google Cloud  