#!/usr/bin/env bash
set -euo pipefail

# Lichess Development Environment Bootstrap Script
# Run this after cloning the lichess workspace to set up everything

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

echo "=========================================="
echo "Lichess Development Environment Bootstrap"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check for Homebrew (macOS)
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        error "Homebrew not found. Install from https://brew.sh"
        exit 1
    fi
    info "Homebrew found"
}

# Install dependencies via Homebrew
install_dependencies() {
    info "Installing dependencies via Homebrew..."

    # Java 21
    if ! brew list openjdk@21 &> /dev/null; then
        info "Installing OpenJDK 21..."
        brew install openjdk@21
    else
        info "OpenJDK 21 already installed"
    fi

    # Coursier (for sbt)
    if ! command -v cs &> /dev/null && ! command -v coursier &> /dev/null; then
        info "Installing Coursier..."
        brew install coursier
        coursier setup --yes
    else
        info "Coursier already installed"
    fi

    # Node.js and pnpm
    if ! command -v pnpm &> /dev/null; then
        info "Installing pnpm..."
        brew install pnpm
    else
        info "pnpm already installed"
    fi

    # MongoDB
    if ! brew list mongodb-community@8.0 &> /dev/null; then
        info "Installing MongoDB 8.0..."
        brew tap mongodb/brew
        brew install mongodb-community@8.0
    else
        info "MongoDB already installed"
    fi

    # Redis
    if ! brew list redis &> /dev/null; then
        info "Installing Redis..."
        brew install redis
    else
        info "Redis already installed"
    fi

    # Python 3.12 (for db seeding)
    if ! brew list python@3.12 &> /dev/null; then
        info "Installing Python 3.12..."
        brew install python@3.12
    else
        info "Python 3.12 already installed"
    fi
}

# Clone repositories
clone_repos() {
    info "Cloning Lichess repositories..."

    declare -A repos=(
        ["lila"]="https://github.com/lichess-org/lila.git"
        ["lila-ws"]="https://github.com/lichess-org/lila-ws.git"
        ["lila-db-seed"]="https://github.com/lichess-org/lila-db-seed.git"
        ["chessground"]="https://github.com/lichess-org/chessground.git"
        ["chessops"]="https://github.com/lichess-org/chessops.git"
        ["lila-openingexplorer"]="https://github.com/lichess-org/lila-openingexplorer.git"
        ["scalachess"]="https://github.com/lichess-org/scalachess.git"
    )

    for repo in "${!repos[@]}"; do
        if [ -d "$repo" ]; then
            info "$repo already exists, skipping clone"
        else
            info "Cloning $repo..."
            git clone "${repos[$repo]}"
        fi
    done
}

# Set up forks (optional, requires gh CLI)
setup_forks() {
    if ! command -v gh &> /dev/null; then
        warn "GitHub CLI (gh) not found. Skipping fork setup."
        warn "Install with: brew install gh"
        return
    fi

    if ! gh auth status &> /dev/null; then
        warn "Not logged into GitHub CLI. Skipping fork setup."
        warn "Login with: gh auth login"
        return
    fi

    info "Setting up forks..."

    local repos=("lila" "chessground" "chessops" "lila-openingexplorer")

    for repo in "${repos[@]}"; do
        if [ -d "$repo" ]; then
            cd "$repo"

            # Check if fork already set up
            if git remote get-url origin 2>/dev/null | grep -qv "lichess-org"; then
                info "$repo fork already configured"
            else
                info "Forking $repo..."
                gh repo fork "lichess-org/$repo" --clone=false 2>/dev/null || true

                # Get GitHub username
                local username=$(gh api user --jq '.login')

                # Reconfigure remotes
                git remote rename origin upstream 2>/dev/null || true
                git remote add origin "git@github.com:$username/$repo.git" 2>/dev/null || true
                info "$repo: origin -> $username/$repo, upstream -> lichess-org/$repo"
            fi

            cd "$ROOT_DIR"
        fi
    done
}

# Initialize lila
init_lila() {
    if [ ! -d "lila" ]; then
        error "lila directory not found"
        return
    fi

    cd lila

    info "Setting up lila..."

    # Enable corepack for pnpm
    corepack enable 2>/dev/null || npm install -g corepack --force

    # Build frontend
    info "Building frontend assets (this may take a few minutes)..."
    ./ui/build

    cd "$ROOT_DIR"
}

# Initialize MongoDB indexes
init_mongodb() {
    info "Starting MongoDB..."
    brew services start mongodb-community@8.0 || true

    sleep 2

    if [ -f "lila/bin/mongodb/indexes.js" ]; then
        info "Creating MongoDB indexes..."
        mongosh lichess < lila/bin/mongodb/indexes.js
    fi
}

# Initialize Redis
init_redis() {
    info "Starting Redis..."
    brew services start redis || true
}

# Set up lila-db-seed
init_db_seed() {
    if [ ! -d "lila-db-seed" ]; then
        warn "lila-db-seed not found, skipping"
        return
    fi

    cd lila-db-seed/spamdb

    if [ ! -d "venv" ]; then
        info "Setting up Python virtual environment for db seeding..."
        python3.12 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
        deactivate
    else
        info "Python venv already exists"
    fi

    cd "$ROOT_DIR"
}

# Print summary
print_summary() {
    echo ""
    echo "=========================================="
    echo "Bootstrap Complete!"
    echo "=========================================="
    echo ""
    echo "To start the development servers:"
    echo ""
    echo "1. Start lila-ws (Terminal 1):"
    echo "   cd lila-ws"
    echo "   JAVA_HOME=$(brew --prefix openjdk@21) sbt 'run -Dcsrf.origin=http://localhost:9663'"
    echo ""
    echo "2. Start lila (Terminal 2):"
    echo "   cd lila"
    echo "   JAVA_HOME=$(brew --prefix openjdk@21) sbt run"
    echo ""
    echo "3. Open http://localhost:9663"
    echo ""
    echo "To seed the database with test data:"
    echo "   cd lila-db-seed/spamdb"
    echo "   source venv/bin/activate"
    echo "   python spamdb.py --users 50 --games 500"
    echo ""
    echo "Default login: any username with password 'password'"
    echo ""
}

# Main
main() {
    check_homebrew
    install_dependencies
    clone_repos
    setup_forks
    init_mongodb
    init_redis
    init_lila
    init_db_seed
    print_summary
}

main "$@"
