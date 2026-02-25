#!/bin/bash
# Run pre-flight checks before creating a PR
#
# Usage: ./scripts/pr-preflight.sh
#
# This script:
# 1. Verifies you're not on main/master branch
# 2. Shows uncommitted changes (for review)
# 3. Detects project type and runs appropriate checks
# 4. Checks if a PR already exists for this branch
#
# Exit codes:
# 0 - All checks passed
# 1 - On main/master branch (cannot create PR)
# 2 - Build or test failed

set -e

echo "PR Pre-flight Checks"
echo "===================="
echo ""

# Step 1: Verify not on main/master
echo "1. Checking branch..."
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  echo "   ERROR: Cannot create PR from $CURRENT_BRANCH branch" >&2
  exit 1
fi
echo "   Branch: ${CURRENT_BRANCH}"
echo ""

# Step 2: Check for uncommitted changes (before running tests)
echo "2. Git status:"
git status --short
if [ -n "$(git status --porcelain)" ]; then
  echo "   Note: You have uncommitted changes"
fi
echo ""

# Step 3: Run verification based on project type
echo "3. Running checks..."

SCALA_PROJECT=false
TS_PROJECT=false

if [ -f "build.sbt" ]; then
  SCALA_PROJECT=true
fi

if [ -f "package.json" ]; then
  TS_PROJECT=true
fi

if [ "$SCALA_PROJECT" = true ]; then
  echo "   Scala project detected"
  echo "   Running sbt compile..."
  if ! sbt compile; then
    echo "   ERROR: sbt compile failed" >&2
    exit 2
  fi
  echo "   Running sbt test..."
  if ! sbt test; then
    echo "   ERROR: sbt test failed" >&2
    exit 2
  fi
  echo "   Scala checks passed"
fi

if [ "$TS_PROJECT" = true ]; then
  echo "   TypeScript project detected"
  echo "   Running pnpm install..."
  pnpm install --frozen-lockfile 2>/dev/null || pnpm install

  # Run lint if available (non-blocking warning)
  if grep -q '"lint"' package.json; then
    echo "   Running pnpm lint..."
    if ! pnpm lint; then
      echo "   WARNING: lint failed (non-blocking)" >&2
    fi
  fi

  echo "   Running pnpm build..."
  if ! pnpm build; then
    echo "   ERROR: pnpm build failed" >&2
    exit 2
  fi
  if grep -q '"test"' package.json; then
    echo "   Running pnpm test..."
    if ! pnpm test; then
      echo "   ERROR: pnpm test failed" >&2
      exit 2
    fi
  fi
  echo "   TypeScript checks passed"
fi

if [ "$SCALA_PROJECT" = false ] && [ "$TS_PROJECT" = false ]; then
  echo "   No Scala or TypeScript project detected (config/docs only)"
fi
echo ""

# Step 4: Check for existing PR
echo "4. Checking for existing PR..."
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [ -n "$REPO" ]; then
  if gh pr view "${CURRENT_BRANCH}" --repo "$REPO" >/dev/null 2>&1; then
    echo "   PR already exists for this branch in $REPO"
  else
    echo "   No existing PR in $REPO - ready to create one"
  fi
else
  echo "   Could not determine repository (not a GitHub repo?)"
fi
echo ""

echo "Pre-flight checks complete!"
