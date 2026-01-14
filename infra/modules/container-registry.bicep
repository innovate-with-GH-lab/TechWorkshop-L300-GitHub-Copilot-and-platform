@description('Container Registry name')
param name string

@description('Location for the Container Registry')
param location string = resourceGroup().location

@description('SKU for the Container Registry')
param sku string = 'Basic'

@description('Admin user enabled')
param adminUserEnabled bool = false

@description('Tags to apply to the resource')
param tags object = {}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
      azureADAuthenticationAsArmPolicy: {
        status: 'enabled'
      }
      softDeletePolicy: {
        retentionDays: 7
        status: 'disabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
    anonymousPullEnabled: false
  }
}

@description('Container Registry ID')
output registryId string = containerRegistry.id

@description('Container Registry login server')
output loginServer string = containerRegistry.properties.loginServer

@description('Container Registry name')
output registryName string = containerRegistry.name
