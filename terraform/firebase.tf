# Enable Firebase APIs
resource "google_project_service" "firebase" {
  project = var.project_id
  service = "firebase.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "firebase_hosting" {
  project = var.project_id
  service = "firebasehosting.googleapis.com"

  disable_on_destroy = false
}

# Initialize Firebase for the project
# Note: This uses the null_resource with local-exec as there's no native Terraform resource
resource "null_resource" "firebase_init" {
  # Only run if Firebase APIs are enabled
  depends_on = [
    google_project_service.firebase,
    google_project_service.firebase_hosting
  ]

  provisioner "local-exec" {
    command = "gcloud alpha firebase projects:addfirebase ${var.project_id} || true"
  }

  # Trigger re-run if project changes
  triggers = {
    project_id = var.project_id
  }
}
