# Authentication System Documentation

FitGlue uses **Firebase Authentication** for user identity and security.

## Architecture

1.  **Identity**: Firebase Auth (Google Identity Platform) manages users, passwords, and OAuth providers (Google, Apple, etc.).
2.  **Frontend**: The web app at `/app` uses the Firebase JS SDK to sign users in.
3.  **Backend**:
    *   **Auth Handler**: A Cloud Function (`auth-handler`) listens for new Auth user creation events and automatically creates/syncs a Document in the `users` Firestore collection.
    *   **Security Rules**: Firestore Security Rules allow users to read/write only their own document (`/users/{userId}`).
    *   **Background Jobs**: Background services (like `strava-uploader`) bypass rules using the Admin SDK.

## Local Development

### Creating a Test User

You can inject a user for local development using the Admin CLI. This creates a real Firebase Auth user (valid for local emulators or dev project) and ensures the Firestore profile exists.

```bash
# Basic usage (interactive)
npm start users:create

# With Auth injection (bypasses UI registration)
npm start users:create -- --email=test@example.com --password=password123
```

### Frontend Development

The frontend is a Vite + React app located in `web/`.

```bash
cd web
npm run dev
# App runs at http://localhost:3000/app
```

The app is rewritten to `/app/**` in production via Firebase Hosting.

## Deployment

The system consists of:
1.  **Hosting**: Static files in `web/public` and the SPA app.
2.  **Functions**: `auth-handler` (needs deployment to GCP).
3.  **Security Rules**: `firestore.rules`.

Deploy using Firebase CLI or Terraform (depending on current infra setup).
