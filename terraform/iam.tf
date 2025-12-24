# NOTE: The service account and IAM bindings are created by scripts/setup_web_deployer.sh
# Terraform does not manage these resources to avoid permission issues and conflicts.
# The bootstrap script creates:
# - circleci-web-deployer service account
# - Firebase Hosting Admin role
# - Storage Object Admin role
# - Workload Identity User binding
# - Service Account Token Creator binding

# If you need to reference the service account in other resources, use a data source:
# data "google_service_account" "circleci_web_deployer" {
#   account_id = "circleci-web-deployer"
#   project    = var.project_id
# }
