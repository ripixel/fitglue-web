# Service account for CircleCI web deployments
resource "google_service_account" "circleci_web_deployer" {
  account_id   = "circleci-web-deployer"
  display_name = "CircleCI Web Deployer"
  description  = "Service account for deploying web frontend via CircleCI"
}

# Grant Firebase Hosting Admin role
resource "google_project_iam_member" "circleci_firebase_admin" {
  project = var.project_id
  role    = "roles/firebasehosting.admin"
  member  = "serviceAccount:${google_service_account.circleci_web_deployer.email}"
}

# Grant Storage Object Admin for hosting files
resource "google_project_iam_member" "circleci_storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.circleci_web_deployer.email}"
}

# Get project number for workload identity pool path
data "google_project" "project" {
  project_id = var.project_id
}

# Allow the CircleCI OIDC tokens to impersonate the web deployer service account
# Note: Uses wildcard pattern to match the server repo configuration
# The workload identity pool is created and managed by the server repo
resource "google_service_account_iam_member" "circleci_web_workload_identity" {
  service_account_id = google_service_account.circleci_web_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/circleci-pool/*"
}

# Grant Token Creator permission to the workload identity pool
# This allows the pool to generate access tokens for the service account
resource "google_service_account_iam_member" "circleci_web_token_creator" {
  service_account_id = google_service_account.circleci_web_deployer.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/circleci-pool/*"
}
