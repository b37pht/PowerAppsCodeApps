#!/bin/bash
# Installs dependencies for the Playwright tests and the templates they cover,
# so lint, build and e2e tests work in Claude Code cloud sessions.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

# Matches CI: npm ci for the test harness, npm install for templates (no lockfiles).
(cd tests && npm ci --no-audit --no-fund)

for dir in templates/vite templates/starter; do
  echo "Installing dependencies in $dir"
  (cd "$dir" && npm install --no-audit --no-fund)
done

# Use the container's preinstalled Chromium; its build may differ from the pinned Playwright's.
if [ -x /opt/pw-browsers/chromium ] && [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo 'export PLAYWRIGHT_CHROMIUM_EXECUTABLE=/opt/pw-browsers/chromium' >> "$CLAUDE_ENV_FILE"
fi
