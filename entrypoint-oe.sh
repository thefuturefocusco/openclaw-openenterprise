#!/bin/sh
set -e

CONFIG_DIR="/home/node/.openclaw"
CONFIG_FILE="${CONFIG_DIR}/openclaw.json"
OE_MODEL="${OPENCLAW_OE_MODEL:-openrouter/anthropic/claude-opus-4}"
OE_URL="${OPENCLAW_OE_SERVICE_URL:-}"

mkdir -p "${CONFIG_DIR}"

if [ -n "${OE_URL}" ]; then
  ORIGINS_LINE="\"allowedOrigins\": [\"${OE_URL}\"],"
else
  ORIGINS_LINE=""
fi

cat > "${CONFIG_FILE}" << EOF
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
      ${ORIGINS_LINE}
      "dangerouslyAllowHostHeaderOriginFallback": true
    }
  },
  "agents": {
    "defaults": {
      "models": {
        "${OE_MODEL}": {}
      },
      "model": {
        "primary": "${OE_MODEL}"
      }
    }
  }
}
EOF

echo "[entrypoint-oe] model=${OE_MODEL} port=${PORT:-8080} origin=${OE_URL:-<host-header>}"

exec node openclaw.mjs gateway --allow-unconfigured
