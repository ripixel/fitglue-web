# Architecture & Design Decisions

This document records key architectural and design decisions for the FitGlue web project.

## 001 - Shared GCP Projects with Server Repo (2025-12-24)

### Context
The web and server repos need to work together to implement the Unified URL Strategy, where all endpoints are accessible via a single domain (e.g., `fitglue.tech`).

### Decision
The web and server repos deploy to the **same GCP projects**:
- `fitglue-server-dev`
- `fitglue-server-test`
- `fitglue-server-prod`

### Rationale
Firebase Hosting rewrites only work when the hosting site and Cloud Functions are in the same GCP project. This enables:
- `/` → Static landing page (web repo)
- `/hooks/{provider}` → Webhook handlers (server repo)
- `/api/**` → API service (server repo)
- `/auth/{provider}/callback` → OAuth callbacks (server repo)

### Consequences
- **Pros**: Zero-cost routing via Firebase Hosting, no CORS issues, clean URLs
- **Cons**: Coordination required between repos, both deploy to same project

See server repo's [Decision 008](https://github.com/ripixel/fitglue-server/blob/main/docs/DECISIONS.md#008---project--repository-architecture-2025-12-24) for full context.

## 002 - Separate Service Accounts for Web and Server (2025-12-24)

### Context
Both web and server repos deploy to the same GCP projects via CircleCI OIDC authentication.

### Decision
Use separate service accounts with different permissions:
- **Server**: `circleci-deployer` with broad Editor role
- **Web**: `circleci-web-deployer` with limited Firebase Hosting + Storage roles

### Rationale
Principle of least privilege - the web deployer only needs to:
- Deploy to Firebase Hosting (`roles/firebasehosting.admin`)
- Upload hosting files (`roles/storage.objectAdmin`)

It doesn't need to create Cloud Functions, manage Firestore, or other server infrastructure.

### Consequences
- **Pros**: Better security, clear separation of concerns
- **Cons**: Requires separate bootstrap process for web deployer

## 003 - Wildcard Workload Identity Binding (2025-12-24)

### Context
CircleCI uses OIDC to authenticate with GCP via workload identity federation. We initially tried using specific attribute filters to distinguish between server and web deployments.

### Decision
Use **wildcard pattern (`/*`)** for workload identity bindings instead of specific attribute filters.

**Correct**:
```
principalSet://iam.googleapis.com/projects/{PROJECT_NUMBER}/locations/global/workloadIdentityPools/circleci-pool/*
```

**Incorrect** (doesn't work):
```
principalSet://iam.googleapis.com/projects/{PROJECT_NUMBER}/locations/global/workloadIdentityPools/circleci-pool/attribute.project_id/{CIRCLECI_ORG_ID}
```

### Rationale
After extensive troubleshooting, we discovered that:
1. The server repo uses wildcard pattern and it works
2. Specific attribute filters cause `Permission 'iam.serviceAccounts.getAccessToken' denied` errors
3. CircleCI OIDC tokens don't provide enough flexibility for custom attribute filtering

Separation between server and web is achieved by:
- Different service accounts
- Different permissions
- CircleCI specifies which service account to use in credential config

### Consequences
- **Pros**: Authentication works reliably, matches server pattern
- **Cons**: Can't use attribute-based filtering to restrict access

## 004 - Bootstrap Script Instead of Terraform for IAM (2025-12-24)

### Context
IAM configuration (service accounts, role bindings) needs to be created before CircleCI can deploy.

### Decision
Use a **bootstrap script** (`scripts/setup_web_deployer.sh`) to create IAM resources instead of managing them with Terraform.

### Rationale
Chicken-and-egg problem:
1. Terraform needs the service account to authenticate
2. But Terraform can't create the service account without authentication
3. The web deployer service account has minimal permissions (Firebase + Storage), not enough to create service accounts or manage IAM

### Consequences
- **Pros**: Simple one-time setup, no permission conflicts, can be re-run safely
- **Cons**: IAM configuration not in Terraform state, manual step required

The Terraform configuration documents what the bootstrap script creates but doesn't manage it.

## 005 - No Build Step (2025-12-24)

### Context
The landing page is simple HTML and CSS.

### Decision
No build step - serve static files directly.

### Rationale
- Faster development (no build wait)
- Simpler deployment
- Easier to understand and maintain
- Sufficient for current needs (landing page)

### Consequences
- **Pros**: Fast, simple, no build complexity
- **Cons**: If we need JavaScript frameworks later, will need to add build step

Future enhancement: Add build step when adding dashboard/app functionality.

## 006 - Vibrant Color Palette (2025-12-24)

### Context
User requested a modern, eye-catching design inspired by ripixel.co.uk.

### Decision
Use a vibrant color palette with high saturation:
- Primary: `#FF006E` (bright pink)
- Secondary: `#8338EC` (vivid purple)
- Accent: `#3A86FF` (electric blue)
- Success: `#06FFA5` (neon green)

With automatic dark mode support.

### Rationale
- Stands out from generic landing pages
- Creates strong first impression
- Aligns with user's design preferences
- Modern and professional

### Consequences
- **Pros**: Memorable, modern, professional
- **Cons**: May not appeal to everyone (but that's okay for a personal project)
