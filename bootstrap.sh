#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd -- "$ROOT_DIR/.." && pwd)"

BACKEND_REPO="${BACKEND_REPO:-https://github.com/PaboluManohar/DevAutoFlow-Backend.git}"
FRONTEND_REPO="${FRONTEND_REPO:-https://github.com/PaboluManohar/DevAutoFlow-UI.git}"
MCP_REPO="${MCP_REPO:-https://github.com/PaboluManohar/DevAutoFlow-MCP.git}"

info() {
  printf '\n[DevAutoFlow] %s\n' "$1"
}

fail() {
  printf '\n[DevAutoFlow] ERROR: %s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

checkout_service() {
  local directory="$1"
  local repository="$2"
  local path="$WORKSPACE_DIR/$directory"

  if [[ -d "$path/.git" ]]; then
    info "$directory already exists; keeping the existing checkout"
    return
  fi

  if [[ -e "$path" ]]; then
    fail "$path exists but is not a Git checkout. Move it aside and run this script again."
  fi

  info "Cloning $directory from $repository"
  git clone "$repository" "$path"
}

cd "$ROOT_DIR"

require_command git
require_command docker

docker compose version >/dev/null 2>&1 || fail "Docker Compose v2 is required (try: docker compose version)"

info "Checking out service repositories"
checkout_service "DevAutoFlow-Backend" "$BACKEND_REPO"
checkout_service "DevAutoFlow-UI" "$FRONTEND_REPO"
checkout_service "DevAutoFlow-MCP" "$MCP_REPO"

if [[ ! -f .env ]]; then
  [[ -f .env.example ]] || fail "Missing .env.example in $ROOT_DIR"
  cp .env.example .env
  info "Created .env from .env.example"
else
  info "Using existing .env"
fi

if command -v adb >/dev/null 2>&1; then
  info "Starting the host ADB server"
  adb -a start-server >/dev/null
else
  printf '\n[DevAutoFlow] WARNING: adb is not installed; Android device automation may not work.\n'
fi

info "Building and starting Docker Compose services"
docker compose up --build -d

info "Service status"
docker compose ps

cat <<'EOF'

DevAutoFlow is starting.

Frontend:    http://localhost:5050
Backend API: http://localhost:5051/docs
MCP:         http://localhost:5052/mcp
PostgreSQL:  localhost:5053

Useful commands:
  docker compose logs -f
  docker compose ps
  docker compose down
EOF