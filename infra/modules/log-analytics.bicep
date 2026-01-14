@description('Log Analytics Workspace name')
param name string

@description('Location for the Log Analytics Workspace')
param location string = resourceGroup().location

@description('Log Analytics Workspace SKU')
param sku string = 'PerGB2018'

@description('Log retention in days')
param retentionInDays int = 30

@description('Tags to apply to the resource')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: 1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('Log Analytics Workspace ID')
output workspaceId string = logAnalyticsWorkspace.id

@description('Log Analytics Workspace Customer ID')
output customerId string = logAnalyticsWorkspace.properties.customerId
