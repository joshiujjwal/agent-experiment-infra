using './main.bicep'

// Copy/edit these values, then deploy directly with:
//   az deployment group create -g <rg> -f infra/main.bicep -p infra/main.bicepparam
// (or just use ../deploy.sh which renders cloud-init for you first).

param name = 'agentlab'
param location = 'eastus'
param vmSize = 'Standard_B2s'
param adminUsername = 'azureuser'
// Paste your SSH public key contents here, or pass on the CLI.
param adminPublicKey = 'ssh-ed25519 AAAA... you@example.com'
// Lock SSH to your IP, e.g. '203.0.113.4/32'. '*' allows any (not recommended).
param sshSourceAddressPrefix = '*'
param osDiskSizeGb = 64
