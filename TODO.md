# agent-experiment-infra — Task Breakdown

## How to Use This File
Workflow per task:
1. Write a check/test FIRST (red) — e.g. `shellcheck`, `bicep build`, a bats test.
2. Implement until it passes (green).
3. Review the diff manually.
4. Commit with a descriptive message.
5. Record anything learned in "Lessons Learned" (compound loop).

## Phase 0: Foundation ✅
- [x] Bicep VM + network + NSG
- [x] cloud-init bootstrap (Node 22, Ollama, OpenClaw)
- [x] `deploy.sh` renders cloud-init + deploys
- [x] `bicep build` passes
- [x] AI config files (CLAUDE.md, AGENTS.md, copilot-instructions)

## Phase 1: Prove the VM boots and installs ⬜
- [ ] Deploy to a real RG; capture `az deployment` outputs as evidence
- [ ] SSH in; confirm `node --version` == 22.x
- [ ] Confirm Ollama service is up (`curl 127.0.0.1:11434/api/tags`)
- [ ] Confirm `openclaw --version` works
- [ ] Document actual first-boot time in Lessons Learned

## Phase 2: Run Hermes ⬜
- [ ] Choose a model tag that fits the VM RAM (or resize VM)
- [ ] `ollama pull` succeeds; smoke test returns text
- [ ] Benchmark tokens/sec on the chosen size

## Phase 3: Run OpenClaw against Hermes ⬜
- [ ] `openclaw onboard` with provider=Ollama, model=hermes3
- [ ] Connect one channel (e.g. Telegram) end-to-end
- [ ] Verify a tool/skill action executes
- [ ] Capture evidence (screenshot / transcript)

## Phase 4: Harden & Ship ⬜
- [ ] Lock NSG SSH to a specific CIDR by default
- [ ] Add `shellcheck` + `bicep build` in GitHub Actions CI
- [ ] Add auto-shutdown schedule to save cost
- [ ] Document teardown + cost estimate

## Parking Lot 🅿️
- [ ] GPU VM variant param set for larger Hermes models
- [ ] Optional: persist Ollama models on a data disk
- [ ] Optional: Tailscale instead of public SSH

## Lessons Learned 📝
- `Standard_B2s` (4 GB) is too small for `hermes3` 8B — size for the model.
- cloud-init scripts are injected via base64 at deploy time so Bicep can `loadFileAsBase64` a single rendered file.
