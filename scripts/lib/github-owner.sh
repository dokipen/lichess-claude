#!/usr/bin/env bash
# Detect the GitHub username of the currently authenticated user.
# Sources in order: GH_OWNER env var, gh CLI auth.
#
# Usage (in other scripts):
#   source "$(dirname "$0")/lib/github-owner.sh"
#   echo "Your fork: $GITHUB_OWNER/lila"

if [ -n "$GH_OWNER" ]; then
  GITHUB_OWNER="$GH_OWNER"
elif command -v gh &> /dev/null && gh auth status &> /dev/null; then
  GITHUB_OWNER=$(gh api user --jq '.login' 2>/dev/null)
fi

if [ -z "$GITHUB_OWNER" ]; then
  echo "Warning: Could not detect GitHub username." >&2
  echo "Set GH_OWNER env var or run 'gh auth login'." >&2
fi

export GITHUB_OWNER
