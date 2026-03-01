# Lichess Development Environment

Local development setup for contributing to the [Lichess](https://lichess.org) open source chess platform.

## New Checkout? Run Bootstrap

If you're setting up from scratch, run the bootstrap script:

```bash
./scripts/bootstrap.sh
```

This will install all dependencies, clone repositories, set up forks, build the frontend, and initialize the database.

## Repository Structure

```
lichess/
├── lila/                    # Main Lichess server (Scala + TypeScript)
├── lila-ws/                 # WebSocket server for real-time features
├── lila-db-seed/            # Database seeding tool
├── chessground/             # Interactive chess board component
├── chessops/                # TypeScript chess library
├── lila-openingexplorer/    # Opening database service (Rust)
└── scalachess/              # Scala chess rules engine
```

## Prerequisites

All dependencies can be installed via [Homebrew](https://brew.sh) on macOS.

### Required Services

| Service | Version | Install Command | Purpose |
|---------|---------|-----------------|---------|
| **Java JDK** | 21+ | `brew install openjdk@21` | Scala runtime for lila backend |
| **Coursier/sbt** | 2+ | `brew install coursier && coursier setup` | Scala build tool |
| **Node.js** | 24+ | `brew install node` | Frontend build tooling |
| **pnpm** | 10+ | `brew install pnpm` | Fast Node.js package manager |
| **MongoDB** | 6.x-8.x | See below | Primary database |
| **Redis** | 7+ | `brew install redis` | Caching, real-time pubsub |
| **Python** | 3.10+ | `brew install python@3.12` | Database seeding scripts |

### Install All Dependencies

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install all dependencies
brew install openjdk@21 coursier node pnpm redis python@3.12

# MongoDB requires tapping the MongoDB repo first
brew tap mongodb/brew
brew install mongodb-community@8.0

# Set up Coursier (installs sbt)
coursier setup --yes
```

### Service Details

#### Java (OpenJDK 21)

Lichess requires JDK 21+. After installing, you may need to set `JAVA_HOME`:

```bash
# Add to ~/.zshrc or ~/.bash_profile
export JAVA_HOME=$(brew --prefix openjdk@21)
export PATH="$JAVA_HOME/bin:$PATH"
```

Verify installation:
```bash
java -version  # Should show 21.x.x
```

#### MongoDB

MongoDB stores all persistent data (users, games, studies, etc.).

```bash
# Install
brew tap mongodb/brew
brew install mongodb-community@8.0

# Start as background service
brew services start mongodb-community@8.0

# Verify it's running
mongosh --eval "db.runCommand({ ping: 1 })"
```

Data is stored at `$(brew --prefix)/var/mongodb` by default.

#### Redis

Redis handles caching, session storage, and real-time communication between lila and lila-ws.

```bash
# Install and start
brew install redis
brew services start redis

# Verify it's running
redis-cli ping  # Should return PONG
```

#### Coursier & sbt

Coursier is a Scala artifact fetcher that also installs sbt (Scala Build Tool):

```bash
brew install coursier
coursier setup --yes

# Verify sbt is available
sbt --version
```

If `sbt` is not found after setup, add Coursier's bin to your PATH:
```bash
export PATH="$HOME/Library/Application Support/Coursier/bin:$PATH"
```

#### Node.js & pnpm

Used for building TypeScript and SCSS frontend assets:

```bash
brew install node pnpm

# Verify
node --version  # Should be 24+
pnpm --version  # Should be 10+
```

#### Python 3.12

Required only for database seeding (lila-db-seed):

```bash
brew install python@3.12

# The seed script creates its own virtual environment
# No global packages needed
```

## Quick Start

### 1. Start Background Services

```bash
./scripts/start-services.sh
# Or manually:
brew services start mongodb-community@8.0
brew services start redis
```

### 2. Start lila-ws (WebSocket Server)

In a terminal:

```bash
cd lila-ws
JAVA_HOME=$(brew --prefix openjdk@21) sbt "run -Dcsrf.origin=http://localhost:9663"
```

Wait until you see: `Listening to 9664`

### 3. Start lila (Main Server)

In another terminal:

```bash
cd lila
JAVA_HOME=$(brew --prefix openjdk@21) sbt run
```

First run compiles everything (~5 minutes). Wait until you see:
```
Listening for HTTP on /[0:0:0:0:0:0:0:0]:9663
```

### 4. Open in Browser

Navigate to **http://localhost:9663**

## Database Seeding

To populate the database with test users, games, puzzles, etc:

```bash
./scripts/seed-db.sh [users] [games]
# Example: ./scripts/seed-db.sh 100 1000

# Or manually:
cd lila-db-seed/spamdb
source venv/bin/activate
python spamdb.py --users 50 --games 500
```

**Default credentials:** Any generated username with password `password`

Special users: `admin`, `superadmin`, `teacher`, `shusher` (all use password `password`)

### Seeding Options

```bash
python spamdb.py --help                    # See all options
python spamdb.py --users 100 --games 1000  # More data
python spamdb.py --drop                    # Reset seeded data
```

## Development Workflow

### Frontend Changes (TypeScript/SCSS)

Run in watch mode for auto-recompilation:

```bash
cd lila
./ui/build -w
```

### Backend Changes (Scala)

The sbt console auto-recompiles on file changes. Just save and refresh.

### Building Frontend Once

```bash
cd lila
./ui/build
```

## Git Workflow

Repositories are configured with:
- `origin` → Your fork ({your-username}/*)
- `upstream` → Official repo (lichess-org/*)

```bash
# Sync with upstream
git fetch upstream
git rebase upstream/master

# Push feature branch
git checkout -b my-feature
# ... make changes ...
git push origin my-feature
```

## Services & Ports

| Service | Port | Description |
|---------|------|-------------|
| lila | 9663 | Main HTTP server |
| lila-ws | 9664 | WebSocket server |
| MongoDB | 27017 | Database |
| Redis | 6379 | Cache & real-time |

## Troubleshooting

### sbt not found
```bash
coursier setup --yes
source ~/.zprofile  # or ~/.bash_profile
```

### Java version issues
```bash
export JAVA_HOME=$(brew --prefix openjdk@21)
export PATH="$JAVA_HOME/bin:$PATH"
```

### MongoDB connection failed
```bash
brew services restart mongodb-community@8.0
```

### Port already in use
```bash
lsof -i :9663  # Find process
kill -9 <PID>  # Kill it
```

## Resources

- [Lichess GitHub Organization](https://github.com/lichess-org)
- [Development Wiki](https://github.com/lichess-org/lila/wiki/Lichess-Development-Onboarding)
- [Discord #lichess-dev-onboarding](https://discord.gg/lichess)
- [Contributing Guide](https://github.com/lichess-org/lila/blob/master/CONTRIBUTING.md)
