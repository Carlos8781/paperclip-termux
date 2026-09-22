#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

if [[ "${PREFIX:-}" != /data/data/com.termux/files/usr* ]]; then
  echo "Este instalador deve ser executado dentro do Termux." >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PAPERCLIP_HOME="${PAPERCLIP_HOME:-$PREFIX/var/lib/paperclip}"
PGDATA="${PAPERCLIP_PGDATA:-$PREFIX/var/lib/postgresql}"
PGPORT="${PAPERCLIP_PGPORT:-5432}"
DB_NAME="${PAPERCLIP_DB_NAME:-paperclip}"
DB_USER="${PAPERCLIP_DB_USER:-paperclip}"

printf '\n== Paperclip para Termux ==\n'
printf 'Dados: %s\nBanco: %s (porta %s)\n\n' "$PAPERCLIP_HOME" "$DB_NAME" "$PGPORT"

pkg update -y
pkg install -y git nodejs-lts postgresql python make clang pkg-config

if ! command -v pnpm >/dev/null 2>&1; then
  npm install --global --location=global pnpm@9.15.4
fi

if [[ ! -d "$PGDATA/base" ]]; then
  mkdir -p "$PGDATA"
  initdb -D "$PGDATA" -U "$DB_USER" --auth=trust --encoding=UTF8
fi

if ! pg_ctl -D "$PGDATA" status >/dev/null 2>&1; then
  pg_ctl -D "$PGDATA" -o "-h 127.0.0.1 -p $PGPORT" -l "$PGDATA/server.log" start
fi

if ! psql -h 127.0.0.1 -p "$PGPORT" -U "$DB_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1; then
  createdb -h 127.0.0.1 -p "$PGPORT" -U "$DB_USER" "$DB_NAME"
fi

mkdir -p "$PAPERCLIP_HOME/instances/default" "$PAPERCLIP_HOME/logs"
CONFIG="$PAPERCLIP_HOME/instances/default/config.json"
if [[ ! -f "$CONFIG" ]]; then
  cat > "$CONFIG" <<EOF
{
  "\$meta": {"version": 1, "updatedAt": "$(date -Iseconds)", "source": "onboard"},
  "database": {
    "mode": "postgres",
    "connectionString": "postgres://$DB_USER@127.0.0.1:$PGPORT/$DB_NAME",
    "backup": {"enabled": true, "intervalMinutes": 60, "retentionDays": 7, "dir": "$PAPERCLIP_HOME/instances/default/data/backups"}
  },
  "logging": {"mode": "file", "logDir": "$PAPERCLIP_HOME/logs"},
  "server": {"deploymentMode": "local_trusted", "exposure": "private", "bind": "lan", "host": "0.0.0.0", "port": 3100, "allowedHostnames": [], "serveUi": true},
  "auth": {"baseUrlMode": "auto", "disableSignUp": false},
  "storage": {"provider": "local_disk", "localDisk": {"baseDir": "$PAPERCLIP_HOME/instances/default/data/storage"}, "s3": {"bucket": "paperclip", "region": "us-east-1", "prefix": "", "forcePathStyle": false}},
  "secrets": {"provider": "local_encrypted", "strictMode": false, "localEncrypted": {"keyFilePath": "$PAPERCLIP_HOME/instances/default/secrets/master.key"}},
  "telemetry": {"enabled": false},
  "updates": {"checkEnabled": false}
}
EOF
fi

cd "$ROOT_DIR"
pnpm install
printf '\nInstalação concluída. Inicie com:\n  ./scripts/termux-start.sh\n\nDashboard: http://127.0.0.1:3100\n'
