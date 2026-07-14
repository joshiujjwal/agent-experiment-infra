# CLAUDE.md — agent-experiment-infra

Azure VM lab (Bicep + cloud-init) for running Nous Hermes (via Ollama) and
OpenClaw. Keep this file current; it is the session handoff.

## Commands
```bash
# Validate infra (no deploy)
az bicep build --file infra/main.bicep

# Lint scripts
shellcheck scripts/*.sh deploy.sh        # TODO: confirm shellcheck installed

# Deploy (renders cloud-init.yaml, creates RG, deploys)
./deploy.sh <resource-group> [location] [ssh-cidr]

# Teardown
az group delete --name <resource-group> --yes --no-wait
```

## Workflow (do this in order)
1. Read `TODO.md` for current phase.
2. Run static checks first: `az bicep build` + `shellcheck`.
3. Red/green: write the failing check, then implement.
4. Review diff, commit, then update this file + TODO "Lessons Learned".

## Directory map
- `infra/main.bicep` — VM, VNet, subnet, NSG, public IP, NIC.
- `infra/cloud-init.template.yaml` — bootstrap; script bodies injected as base64.
- `infra/cloud-init.yaml` — **generated** by `deploy.sh`; do not edit or commit.
- `scripts/setup-hermes.sh` — pulls Ollama model (`HERMES_MODEL`, default `hermes3`).
- `scripts/setup-openclaw.sh` — `npm i -g openclaw@latest`.
- `deploy.sh` — renders cloud-init from template + scripts, then `az deployment`.

## Conventions & gotchas
- Bicep `loadFileAsBase64('./cloud-init.yaml')` requires the rendered file to
  exist BEFORE build/deploy. `deploy.sh` renders it; `bicep build` alone needs
  it too (render manually if validating without deploy.sh).
- `deploy.sh` replaces `__SETUP_*_B64__` placeholders — keep those tokens intact.
- SSH-key auth only; password auth is disabled. `adminPublicKey` is required.
- `Standard_B2s` = 4 GB RAM; 8B models won't load. Setup scripts fail
  gracefully (exit 0) rather than blocking boot.
- Don't commit `infra/cloud-init.yaml` or `infra/main.json` (build output).

## Credits
Third-party projects bootstrapped here: OpenClaw (openclaw.ai), Ollama, and the
Nous Research Hermes models. Preserve attribution in README when adapting.
