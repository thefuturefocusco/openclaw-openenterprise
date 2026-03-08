#!/bin/sh
set -e

CONFIG_DIR="/home/node/.openclaw"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"
SERVICE_URL="${OPENCLAW_OE_SERVICE_URL:-}"
MODEL="${OPENCLAW_OE_MODEL:-openrouter/anthropic/claude-opus-4}"

mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" <<EOJSON
{
  "gateway": {
    "port": ${PORT:-8080},
    "bind": "lan",
    "http": {
      "endpoints": {
        "chatCompletions": { "enabled": true }
      }
    },
    "controlUi": {
      "dangerouslyAllowHostHeaderOriginFallback": true${SERVICE_URL:+,
      "allowedOrigins": ["${SERVICE_URL}"]}
    }
  },
  "agents": {
    "defaults": {
      "models": {
        "${MODEL}": {}
      },
      "model": {
        "primary": "${MODEL}"
      }
    }
  }
}
EOJSON

echo "[entrypoint-oe] Generated config:"
echo "  model  = ${MODEL}"
echo "  port   = ${PORT:-8080}"
echo "  origin = ${SERVICE_URL:-<host-header fallback>}"

exec node openclaw.mjs gateway --allow-unconfigured
