// Azure VM experiment lab for running Nous Hermes (via Ollama) + OpenClaw.
// Provisions: VNet, subnet, NSG (SSH), public IP, NIC, Linux VM with cloud-init.
targetScope = 'resourceGroup'

@description('Base name used to prefix all resources.')
param name string = 'agentlab'

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('VM size. B2s (4GB) is cheap but too small for 8B local models; use D4s_v5 or a GPU size for local LLMs.')
param vmSize string = 'Standard_B2s'

@description('Admin username for the VM.')
param adminUsername string = 'azureuser'

@description('SSH public key contents for the admin user (e.g. contents of ~/.ssh/id_ed25519.pub).')
@secure()
param adminPublicKey string

@description('Your source IP in CIDR form to lock down SSH (e.g. 203.0.113.4/32). Default allows any (not recommended).')
param sshSourceAddressPrefix string = '*'

@description('OS disk size in GB. Bump up if pulling large models.')
param osDiskSizeGb int = 64

var vnetName = '${name}-vnet'
var subnetName = '${name}-subnet'
var nsgName = '${name}-nsg'
var pipName = '${name}-pip'
var nicName = '${name}-nic'
var vmName = '${name}-vm'
var cloudInit = loadFileAsBase64('./cloud-init.yaml')

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: sshSourceAddressPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.20.0.0/16' ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.20.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: pipName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      customData: cloudInit
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: osDiskSizeGb
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

output publicIp string = pip.properties.ipAddress
output sshCommand string = 'ssh ${adminUsername}@${pip.properties.ipAddress}'
output vmName string = vm.name
