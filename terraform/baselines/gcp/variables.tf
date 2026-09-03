variable "gcp_project" {
  type        = string
  description = "GCP project ID to deploy WIF resources into"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo in OWNER/REPO format allowed to assume this WIF identity via OIDC"
}
