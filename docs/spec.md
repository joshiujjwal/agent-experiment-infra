# Spec — agent-experiment-infra

## Overview
A one-command, disposable Azure environment for experimenting with local AI
agents. It provisions a Linux VM and bootstraps it to run the **Nous Hermes**
LLM (served by Ollama) and the **OpenClaw** agent framework, so experiments are
reproducible and easy to tear down.

## Problem statement
Trying agent stacks locally pollutes your machine and is hard to reproduce.
A throwaway cloud VM defined as code gives a clean, repeatable, shareable lab
that can be destroyed when done.

## Functional requirements
- [ ] Provision an Ubuntu 24.04 VM via Bicep with SSH-key auth only.
- [ ] Network isolation: dedicated VNet/subnet + NSG allowing only SSH.
- [ ] NSG SSH source is parameterizable to a single CIDR.
- [ ] cloud-init installs Node.js 22, Ollama, and OpenClaw unattended.
- [ ] cloud-init pulls a configurable Hermes model tag into Ollama.
- [ ] A single `deploy.sh` renders cloud-init and runs the deployment.
- [ ] Deployment outputs the public IP and a ready-to-use `ssh` command.
- [ ] Full teardown via `az group delete`.

## Non-functional requirements
- [ ] `az bicep build` passes with no errors.
- [ ] Scripts pass `shellcheck`.
- [ ] Idempotent bootstrap (safe to re-run setup scripts).
- [ ] Cheap default; cost controllable via VM size + auto-shutdown.
- [ ] No secrets committed; SSH public key passed at deploy time.

## Data model / parameters
| Param | Default | Purpose |
|---|---|---|
| `name` | `agentlab` | Resource name prefix |
| `location` | `eastus` | Region |
| `vmSize` | `Standard_B2s` | VM SKU |
| `adminUsername` | `azureuser` | Login user |
| `adminPublicKey` | — (required) | SSH public key |
| `sshSourceAddressPrefix` | `*` | NSG SSH source CIDR |
| `osDiskSizeGb` | `64` | OS disk size |
| env `HERMES_MODEL` | `hermes3` | Ollama model tag |

## Interface design
- `./deploy.sh <rg> [location] [ssh-cidr]` — render + deploy.
- On VM: `ollama` (API at `127.0.0.1:11434`), `openclaw` CLI.
- OpenClaw ↔ Hermes wiring: provider `Ollama`, base URL `http://127.0.0.1:11434`, model `hermes3`.

## Test plan
- **Static:** `az bicep build`, `shellcheck scripts/*.sh deploy.sh`.
- **Integration:** deploy to a scratch RG; assert cloud-init log shows Node 22,
  Ollama tags endpoint reachable, `openclaw --version` non-empty.
- **Edge cases:** model too large for RAM (pull fails gracefully, non-fatal);
  missing SSH key (deploy.sh errors early); `*` SSH source warned in docs.

## Open questions
- [ ] Which Hermes tag/quant best fits the default (small) VM?
- [ ] Do we want a data disk to cache pulled models across rebuilds?
- [ ] Expose OpenClaw UI port through NSG, or keep SSH-tunnel only? (default: tunnel)
