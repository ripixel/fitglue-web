# Firebase Hosting Site
#
# Note: Firebase Hosting sites are created automatically on first deployment via Firebase CLI.
# There is no Terraform resource for google_firebase_hosting_site in the Google provider.
#
# The site will be created when CircleCI runs:
#   firebase deploy --only hosting --project fitglue-server-{env}
#
# If you need to pre-create the site manually, use:
#   firebase hosting:sites:create {site-id} --project {project-id}
