#!/usr/bin/env bash
# Pulls the Nous Hermes model into Ollama and verifies it responds.
# Runs on the VM via cloud-init. Idempotent.
set -euo pipefail

# Override with a smaller/larger tag as needed. hermes3 (8B) needs ~6GB RAM.
MODEL="${HERMES_MODEL:-hermes3}"

echo "[hermes] waiting for ollama service..."
for _ in {1..30}; do
  if curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "[hermes] pulling model: ${MODEL}"
if ! ollama pull "${MODEL}"; then
  echo "[hermes] WARNING: pull failed (often insufficient RAM on small VMs)." >&2
  echo "[hermes] Try a GPU/larger VM, or a smaller model: HERMES_MODEL=hermes3:3b" >&2
  exit 0
fi

echo "[hermes] smoke test..."
ollama run "${MODEL}" "Reply with exactly: hermes-ok" || \
  echo "[hermes] WARNING: model did not respond; check RAM." >&2

echo "[hermes] done. Ollama API on http://127.0.0.1:11434"
