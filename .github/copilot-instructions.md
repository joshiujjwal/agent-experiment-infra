# GitHub Copilot Instructions — agent-experiment-infra

## Stack
Azure Bicep (IaC) + cloud-init + bash. Target VM runs Ubuntu 24.04 with
Node.js 22, Ollama (Hermes models), and OpenClaw.

## Coding conventions
- **Bicep:** `@description` on every param; camelCase; parameterize anything
  environment-specific; expose outputs (IP, ssh command). Prefer `@secure()`
  for key material.
- **Bash:** `set -euo pipefail`; quote expansions; idempotent; portable
  base64/sed (works on macOS and Linux); errors to stderr, non-zero exit.
- Never hardcode secrets, subscription IDs, or public keys.

## Testing conventions
- Validate infra with `az bicep build` before proposing changes.
- Lint shell with `shellcheck`.
- Prefer integration proof (real deploy to a scratch RG + log evidence) over
  assertions in description.

## Boundaries
- Only modify files explicitly discussed; don't refactor unrelated code.
- Don't edit or commit generated files (`infra/cloud-init.yaml`, `infra/main.json`).
- Don't remove existing checks/tests.
- Don't loosen the NSG (e.g. open extra ports) unless asked.
- Preserve the `__SETUP_*_B64__` injection tokens in the cloud-init template.
