#!/usr/bin/env bash
set -euo pipefail

# Deploy a site (or both) to RamNode shared hosting via FTP/SFTP.
# Usage:
#   ./scripts/deploy.sh consulting
#   ./scripts/deploy.sh nets-2026
#   ./scripts/deploy.sh all

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ ! -f "$ROOT_DIR/.env" ]]; then
  echo "ERROR: .env file not found. Copy .env.example to .env and fill in your FTP credentials." >&2
  exit 1
fi

# shellcheck disable=SC1091
source "$ROOT_DIR/.env"

: "${FTP_HOST:?FTP_HOST not set in .env}"
: "${FTP_USER:?FTP_USER not set in .env}"
: "${FTP_PASS:?FTP_PASS not set in .env}"
FTP_PORT="${FTP_PORT:-21}"
FTP_PROTOCOL="${FTP_PROTOCOL:-ftp}"   # ftp, ftps, or sftp
REMOTE_BASE="${REMOTE_BASE:-public_html}"

if ! command -v lftp >/dev/null 2>&1; then
  echo "ERROR: lftp is not installed." >&2
  echo "  Install on Mac:   brew install lftp" >&2
  echo "  Install on Linux: sudo apt install lftp" >&2
  exit 1
fi

deploy_one() {
  local site="$1"
  local local_dir="$ROOT_DIR/sites/$site"
  local remote_dir="$REMOTE_BASE/$site"

  if [[ ! -d "$local_dir" ]]; then
    echo "ERROR: Local folder $local_dir does not exist." >&2
    exit 1
  fi

  echo ">> Deploying '$site' -> $FTP_HOST:$remote_dir"

  lftp -u "$FTP_USER","$FTP_PASS" -p "$FTP_PORT" "$FTP_PROTOCOL://$FTP_HOST" <<EOF
set ssl:verify-certificate no
set ftp:ssl-allow yes
mkdir -p $remote_dir
mirror --reverse --delete --verbose --exclude-glob .DS_Store $local_dir $remote_dir
bye
EOF

  echo ">> Done: https://marklevi.com/$site"
}

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <consulting|nets-2026|all>" >&2
  exit 1
fi

case "$1" in
  all)
    deploy_one consulting
    deploy_one nets-2026
    ;;
  consulting|nets-2026)
    deploy_one "$1"
    ;;
  *)
    echo "Unknown site: $1" >&2
    echo "Usage: $0 <consulting|nets-2026|all>" >&2
    exit 1
    ;;
esac
