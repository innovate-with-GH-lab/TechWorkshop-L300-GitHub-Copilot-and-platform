@description('App Service Plan name')
param name string

@description('Location for the App Service Plan')
param location string = resourceGroup().location

@description('App Service Plan SKU')
param sku object = {
  name: 'B1'
  tier: 'Basic'
}

@description('App Service Plan kind')
param kind string = 'linux'

@description('Reserved (required for Linux)')
param reserved bool = true

@description('Tags to apply to the resource')
param tags object = {}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  kind: kind
  properties: {
    reserved: reserved
    isSpot: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

@description('App Service Plan ID')
output appServicePlanId string = appServicePlan.id

@description('App Service Plan name')
output appServicePlanName string = appServicePlan.name
