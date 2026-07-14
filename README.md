# agent-experiment-infra

> 🚧 **Early Development** — Azure VM lab for experimenting with AI agents.

Spin up a disposable Azure VM to try running the **Nous Hermes** model (via [Ollama](https://ollama.com)) and the **[OpenClaw](https://openclaw.ai)** local agent framework, provisioned with **Bicep** + cloud-init.

## What it provisions

| Resource | Detail |
|---|---|
| VM | Ubuntu 24.04 LTS, `Standard_B2s` (configurable) |
| Network | VNet + subnet + NSG (SSH only, IP-lockable) + static public IP |
| Bootstrap | cloud-init installs Node.js 22, Ollama (pulls `hermes3`), and OpenClaw |
| Region | `eastus` (configurable) |

> ⚠️ **RAM caveat:** `Standard_B2s` has 4 GB. The `hermes3` (8B) model needs ~6 GB and will likely fail to load. For local LLMs, use `Standard_D4s_v5`+ or a GPU size (e.g. `Standard_NC4as_T4_v3`), or set a smaller model tag (`HERMES_MODEL=hermes3:3b`).

## Tech stack

- **IaC:** Azure Bicep
- **Bootstrap:** cloud-init + bash
- **Runtime on VM:** Node.js 22, Ollama, OpenClaw

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/) (`az login` done)
- An SSH key pair (`ssh-keygen -t ed25519`)
- An Azure subscription with permission to create resource groups

## Getting started

```bash
# 1. Clone
git clone <repo-url> && cd agent-experiment-infra

# 2. Deploy (renders cloud-init, creates RG, deploys Bicep).
#    Lock SSH to your IP for safety.
./deploy.sh agentlab-rg eastus "$(curl -s ifconfig.me)/32"

# 3. SSH in using the printed sshCommand output
ssh azureuser@<public-ip>

# 4. On the VM, watch bootstrap finish
tail -f /var/log/agentlab-*.log
cat /var/log/agentlab-ready        # appears when done

# 5. Finish OpenClaw onboarding (interactive)
openclaw onboard --install-daemon  # point provider=Ollama, url=http://127.0.0.1:11434, model=hermes3
```

Tear down everything:

```bash
az group delete --name agentlab-rg --yes --no-wait
```

## Project structure

```
agent-experiment-infra/
├── infra/
│   ├── main.bicep              # VM + network + cloud-init
│   ├── main.bicepparam         # editable parameters
│   ├── cloud-init.template.yaml# bootstrap template (scripts injected at deploy)
│   └── cloud-init.yaml         # rendered artifact (gitignored)
├── scripts/
│   ├── setup-hermes.sh         # pulls Hermes model into Ollama
│   └── setup-openclaw.sh       # installs OpenClaw globally
├── deploy.sh                   # render + deploy entrypoint
├── docs/spec.md                # what/why + requirements
└── docs/adr/                   # architecture decisions
```

## Contributing

- **Red/green TDD** for any scripts with logic (bats/shellcheck) — write the failing check first.
- **Small, focused PRs.** One concern per PR.
- **Evidence required:** paste `az deployment` output or VM log snippets proving it works.
- Review AI-generated diffs and PR descriptions yourself before merging.

## Credits

Bootstraps third-party projects — full credit to their authors:
- [OpenClaw](https://openclaw.ai) — local AI agent framework.
- [Ollama](https://ollama.com) and the Nous Research **Hermes** models.
