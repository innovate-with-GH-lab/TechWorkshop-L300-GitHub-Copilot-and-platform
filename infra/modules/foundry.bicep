@description('Microsoft Foundry workspace name')
param workspaceName string

@description('Location for Microsoft Foundry resources')
param location string = resourceGroup().location

@description('SKU for the Microsoft Foundry workspace')
param sku string = 'S0'

@description('Tags to apply to the resource')
param tags object = {}

// Microsoft Foundry workspace
resource foundryWorkspace 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  sku: {
    name: sku
    tier: 'Standard'
  }
  kind: 'Default'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: workspaceName
    description: 'Microsoft Foundry workspace for ZavaStorefront AI services'
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    discoveryUrl: 'https://${location}.api.azureml.ms/discovery'
    enableDataIsolation: false
    encryption: {
      status: 'Disabled'
    }
    hbiWorkspace: false
    publicNetworkAccess: 'Enabled'
    allowPublicAccessWhenBehindVnet: false
  }
}

// Storage Account for Microsoft Foundry
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'st${take(replace(replace(workspaceName, '-', ''), '_', ''), 10)}${take(uniqueString(resourceGroup().id), 8)}'
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

// Key Vault for Microsoft Foundry
resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: 'kv-${take(replace(replace(workspaceName, '-', ''), '_', ''), 8)}-${take(uniqueString(resourceGroup().id), 6)}'
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
  }
}

@description('Microsoft Foundry workspace ID')
output workspaceId string = foundryWorkspace.id

@description('Microsoft Foundry workspace name')
output workspaceName string = foundryWorkspace.name

@description('Storage Account ID')
output storageAccountId string = storageAccount.id

@description('Key Vault ID')
output keyVaultId string = keyVault.id
