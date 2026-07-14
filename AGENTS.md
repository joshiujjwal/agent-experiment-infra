# AGENTS.md

Guidance for AI coding agents working in this repo. Human-facing docs: `README.md`.

## Setup commands
```bash
az login                                  # once
az bicep build --file infra/main.bicep    # validate infra
./deploy.sh <rg> <location> <ssh-cidr>    # deploy
```

## Code style
- **Bicep:** camelCase params/vars; one resource per logical block; add a `@description`
  to every param; prefer parameters over hardcoded values; emit useful `output`s.
- **Bash:** `#!/usr/bin/env bash` + `set -euo pipefail`; quote all expansions;
  keep scripts idempotent; fail early with clear messages to stderr.
- No secrets in code. SSH public key and IP CIDR are passed at deploy time.
- Keep cloud-init injection tokens (`__SETUP_*_B64__`) intact.

## Testing (red/green)
- Write the failing check first, then make it pass.
- Static gates that must pass before commit:
  - `az bicep build --file infra/main.bicep`
  - `shellcheck scripts/*.sh deploy.sh`
- Integration: deploy to a scratch RG, verify VM logs, then delete the RG.

## PR instructions
- Small, single-concern PRs.
- Include **evidence**: `az bicep build` output, `shellcheck` clean run, and/or
  VM log snippets (`/var/log/agentlab-*.log`).
- Review AI-generated diffs AND the PR description before merging — both can be wrong.
- Never remove existing tests/checks.

## Attribution
When adapting third-party install flows (OpenClaw, Ollama, Hermes), keep credit
to the source in README and script comments.
