#!/usr/bin/env bash
set -euo pipefail

# Start MongoDB and Redis background services

echo "Starting background services..."

brew services start mongodb-community@8.0 2>/dev/null || echo "MongoDB already running or failed to start"
brew services start redis 2>/dev/null || echo "Redis already running or failed to start"

echo ""
echo "Services started. Now run in separate terminals:"
echo ""
JAVA_HOME_PATH=$(brew --prefix openjdk@21 2>/dev/null || echo "/opt/homebrew/opt/openjdk@21")

echo "Terminal 1 (lila-ws):"
echo "  cd lila-ws && JAVA_HOME=$JAVA_HOME_PATH sbt 'run -Dcsrf.origin=http://localhost:9663'"
echo ""
echo "Terminal 2 (lila):"
echo "  cd lila && JAVA_HOME=$JAVA_HOME_PATH sbt run"
echo ""
echo "Then open: http://localhost:9663"
