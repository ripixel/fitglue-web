# Local Development

This guide covers running the FitGlue web frontend locally for development.

## Prerequisites

- Node.js 20+
- npm

## Quick Start

```bash
# Install dependencies
npm install

# Start local server
npm run serve
```

The site will be available at `http://localhost:5000` and will automatically open in your browser.

## Available Scripts

### `npm run serve`
Starts a local HTTP server on port 5000 using `http-server`. This doesn't require Firebase project access and is the recommended way to preview the site locally.

### `npm run serve:firebase`
Starts the Firebase Hosting emulator. Requires Firebase project access and authentication. Use this if you need to test Firebase Hosting rewrites locally.

### `npm run lint`
Runs HTML and CSS linting:
- `htmlhint` for HTML validation
- `stylelint` for CSS validation

### `npm run lint:html`
Runs only HTML linting.

### `npm run lint:css`
Runs only CSS linting.

## Project Structure

```
web/
├── public/              # Static files served by Firebase Hosting
│   ├── index.html       # Landing page
│   └── styles.css       # Styles
├── terraform/           # Infrastructure as Code
├── scripts/             # Bootstrap and utility scripts
├── docs/                # Documentation
├── firebase.json        # Firebase Hosting configuration
└── package.json         # Dependencies and scripts
```

## Making Changes

### Editing the Landing Page

1. Edit `public/index.html` for content changes
2. Edit `public/styles.css` for styling changes
3. Refresh your browser to see changes

### Design Guidelines

The landing page follows these principles:
- **Vibrant colors**: Bold, eye-catching palette (pink, purple, blue)
- **Minimalist**: Clean layout with maximum impact
- **Responsive**: Mobile-first approach
- **Dark mode**: Automatic theme switching
- **Smooth animations**: Subtle transitions for professional feel

Color palette:
- Primary: `#FF006E` (bright pink)
- Secondary: `#8338EC` (vivid purple)
- Accent: `#3A86FF` (electric blue)
- Success: `#06FFA5` (neon green)

### Testing Rewrites Locally

To test Firebase Hosting rewrites (e.g., `/hooks/hevy` → Cloud Function):

1. Start the Firebase emulator:
   ```bash
   npm run serve:firebase
   ```

2. The emulator will show warnings about missing Cloud Functions - this is expected since functions are deployed separately

3. To fully test rewrites, deploy to the dev environment

## Linting

Always run linting before committing:

```bash
npm run lint
```

Fix any errors before pushing. The CI pipeline will fail if linting doesn't pass.

### Common Linting Issues

**Hex colors**: Use shorthand when possible (`#FFF` instead of `#FFFFFF`)

**Font family quotes**: Don't quote generic font families
```css
/* Bad */
font-family: 'Roboto', 'sans-serif';

/* Good */
font-family: Roboto, sans-serif;
```

**Keyframe names**: Use kebab-case
```css
/* Bad */
@keyframes fadeIn { }

/* Good */
@keyframes fade-in { }
```

## Firebase Configuration

The `firebase.json` file configures:
- Public directory (`public/`)
- Cache headers for static assets
- Rewrites for Cloud Functions (see [Unified URL Strategy](../README.md#unified-url-strategy))

## No Build Step

The web frontend is intentionally simple - just HTML and CSS with no build step. This keeps development fast and deployment simple.

If you need to add JavaScript or a framework in the future, you'll need to:
1. Add a build step to `package.json`
2. Update `.gitignore` to ignore build artifacts
3. Update `firebase.json` to serve from the build directory
4. Update CircleCI config to run the build

## Troubleshooting

### Port 5000 Already in Use

If port 5000 is already in use, you can specify a different port:

```bash
npx http-server public -p 8080
```

### Firebase Commands Fail

If `npm run serve:firebase` fails with "No project active":

```bash
firebase use fitglue-server-dev
```

### Changes Not Showing

Hard refresh your browser:
- Chrome/Firefox: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)
- Safari: `Cmd+Option+R`
