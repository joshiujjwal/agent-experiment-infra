#!/usr/bin/env bash
# Installs OpenClaw (https://openclaw.ai) globally via npm.
# Onboarding is interactive, so we install only; you finish setup over SSH.
set -euo pipefail

echo "[openclaw] node version: $(node --version 2>/dev/null || echo missing)"

echo "[openclaw] installing openclaw@latest globally..."
if ! npm install -g openclaw@latest; then
  echo "[openclaw] WARNING: npm install failed." >&2
  exit 0
fi

echo "[openclaw] installed: $(openclaw --version 2>/dev/null || echo unknown)"
cat <<'EOF'
[openclaw] Install complete. To finish setup, SSH in and run:

  openclaw onboard --install-daemon

Point it at the local Hermes model (Ollama):
  Provider:  Ollama
  Base URL:  http://127.0.0.1:11434
  Model:     hermes3

Then:
  openclaw ui              # dashboard
  openclaw gateway status  # health
EOF
