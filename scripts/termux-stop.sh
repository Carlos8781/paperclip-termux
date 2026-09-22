#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

: "${PREFIX:=$HOME/.termux-prefix}"
PGDATA="${PAPERCLIP_PGDATA:-$PREFIX/var/lib/postgresql}"
if [[ -d "$PGDATA" ]] && command -v pg_ctl >/dev/null 2>&1; then
  pg_ctl -D "$PGDATA" -m fast stop || true
fi
if command -v termux-wake-unlock >/dev/null 2>&1; then
  termux-wake-unlock || true
fi
echo "PostgreSQL do Paperclip foi parado."
