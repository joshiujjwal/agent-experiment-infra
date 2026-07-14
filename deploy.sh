#!/usr/bin/env bash
# One-shot deploy: builds cloud-init from the template + setup scripts, then
# deploys the Bicep to a resource group. Requires: az cli, an SSH key.
#
# Usage:
#   ./deploy.sh <resource-group> [location] [ssh-source-cidr]
# Example:
#   ./deploy.sh agentlab-rg eastus 203.0.113.4/32
set -euo pipefail

RG="${1:?resource group name required}"
LOCATION="${2:-eastus}"
SSH_CIDR="${3:-*}"
NAME="${AGENTLAB_NAME:-agentlab}"
PUBKEY_PATH="${SSH_PUBKEY_PATH:-$HOME/.ssh/id_ed25519.pub}"

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if [[ ! -f "$PUBKEY_PATH" ]]; then
  echo "ERROR: SSH public key not found at $PUBKEY_PATH" >&2
  echo "Generate one with: ssh-keygen -t ed25519" >&2
  exit 1
fi
PUBKEY="$(cat "$PUBKEY_PATH")"

# Base64 helper (portable across macOS/Linux).
b64() { base64 < "$1" | tr -d '\n'; }

echo "==> Rendering cloud-init.yaml from template + scripts"
HERMES_B64="$(b64 scripts/setup-hermes.sh)"
OPENCLAW_B64="$(b64 scripts/setup-openclaw.sh)"
sed -e "s|__SETUP_HERMES_B64__|${HERMES_B64}|" \
    -e "s|__SETUP_OPENCLAW_B64__|${OPENCLAW_B64}|" \
    infra/cloud-init.template.yaml > infra/cloud-init.yaml

echo "==> Ensuring resource group $RG ($LOCATION)"
az group create --name "$RG" --location "$LOCATION" --output none

echo "==> Deploying Bicep"
az deployment group create \
  --resource-group "$RG" \
  --template-file infra/main.bicep \
  --parameters name="$NAME" location="$LOCATION" \
               adminPublicKey="$PUBKEY" \
               sshSourceAddressPrefix="$SSH_CIDR" \
  --query "properties.outputs" --output json

echo "==> Done. Use the sshCommand output above to connect."
echo "    First boot runs cloud-init; check /var/log/agentlab-ready on the VM."
