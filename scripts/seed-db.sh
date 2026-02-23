#!/usr/bin/env bash
set -euo pipefail

# Seed the database with test data

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR/lila-db-seed/spamdb"

if [ ! -d "venv" ]; then
    echo "Setting up Python virtual environment..."
    /opt/homebrew/bin/python3.12 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
else
    source venv/bin/activate
fi

# Default values
USERS=${1:-50}
GAMES=${2:-500}

echo "Seeding database with $USERS users and $GAMES games..."
python spamdb.py --users "$USERS" --games "$GAMES" --forum-posts 100 --ublog-posts 50 --tours 20

echo ""
echo "Database seeded! Login with any username and password 'password'"
echo "Special users: admin, superadmin, teacher, shusher"
