#!/bin/bash
# Run pre-flight checks before creating a PR
#
# Usage: ./scripts/pr-preflight.sh
#
# This script:
# 1. Verifies you're not on main branch
# 2. Detects which repos have changes and runs appropriate tests
# 3. Shows uncommitted changes (for review)
# 4. Checks if a PR already exists for this branch
#
# Exit codes:
# 0 - All checks passed
# 1 - On main branch (cannot create PR)
# 2 - Build or test failed

set -e

echo "PR Pre-flight Checks"
echo "===================="
echo ""

# Step 1: Verify not on main
echo "1. Checking branch..."
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ]; then
  echo "   ERROR: Cannot create PR from main branch"
  exit 1
fi
echo "   Branch: ${CURRENT_BRANCH}"
echo ""

# Step 2: Run verification based on changed files
echo "2. Running tests for changed repos..."

# Check if we have Scala changes in this repo (lichess-claude)
SCALA_CHANGED=false
TS_CHANGED=false

# For lichess-claude repo, we just check if files changed
if git diff --name-only origin/main...HEAD | grep -q '\.'; then
  echo "   Changes detected in lichess-claude"
fi

# If we're in a sub-repo worktree, check for Scala/TS changes
if [ -f "build.sbt" ]; then
  SCALA_CHANGED=true
fi

if [ -f "package.json" ]; then
  TS_CHANGED=true
fi

if [ "$SCALA_CHANGED" = true ]; then
  echo "   Running sbt compile..."
  if ! sbt compile; then
    echo "   ERROR: sbt compile failed"
    exit 2
  fi
  echo "   Running sbt test..."
  if ! sbt test; then
    echo "   ERROR: sbt test failed"
    exit 2
  fi
  echo "   Scala checks passed"
fi

if [ "$TS_CHANGED" = true ]; then
  echo "   Running pnpm install..."
  pnpm install --frozen-lockfile 2>/dev/null || pnpm install
  echo "   Running pnpm build..."
  if ! pnpm build; then
    echo "   ERROR: pnpm build failed"
    exit 2
  fi
  if [ -f "package.json" ] && grep -q '"test"' package.json; then
    echo "   Running pnpm test..."
    if ! pnpm test; then
      echo "   ERROR: pnpm test failed"
      exit 2
    fi
  fi
  echo "   TypeScript checks passed"
fi

if [ "$SCALA_CHANGED" = false ] && [ "$TS_CHANGED" = false ]; then
  echo "   No Scala or TypeScript project detected (config/docs only changes)"
fi
echo ""

# Step 3: Check for uncommitted changes
echo "3. Git status:"
git status --short
echo ""

# Step 4: Check for existing PR
echo "4. Checking for existing PR..."
if gh pr view "${CURRENT_BRANCH}" --repo dokipen/lichess-claude 2>/dev/null; then
  echo "   PR already exists for this branch"
else
  echo "   No existing PR - ready to create one"
fi
echo ""

echo "Pre-flight checks complete!"
