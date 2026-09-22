#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
: "${PREFIX:=$HOME/.termux-prefix}"
export PAPERCLIP_HOME="${PAPERCLIP_HOME:-$PREFIX/var/lib/paperclip}"
export PAPERCLIP_INSTANCE_ID="${PAPERCLIP_INSTANCE_ID:-default}"
export PAPERCLIP_CONFIG="${PAPERCLIP_CONFIG:-$PAPERCLIP_HOME/instances/$PAPERCLIP_INSTANCE_ID/config.json}"
export PAPERCLIP_DEPLOYMENT_MODE="${PAPERCLIP_DEPLOYMENT_MODE:-local_trusted}"
export PAPERCLIP_BIND="${PAPERCLIP_BIND:-lan}"
export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-3100}"
export PAPERCLIP_OPEN_ON_LISTEN="false"

cd "$ROOT_DIR"
if [[ ! -f "$PAPERCLIP_CONFIG" ]]; then
  echo "Configuração não encontrada: $PAPERCLIP_CONFIG" >&2
  echo "Execute primeiro: ./scripts/termux-install.sh" >&2
  exit 1
fi

if command -v termux-wake-lock >/dev/null 2>&1; then
  termux-wake-lock || true
  trap 'termux-wake-unlock || true' EXIT INT TERM
fi

echo "Paperclip Termux rodando em http://127.0.0.1:$PORT"
echo "Para acesso por outro dispositivo, use o IP local do telefone na porta $PORT."
echo "Pressione Ctrl+C para parar."
exec pnpm --filter @paperclipai/server exec tsx src/index.ts
