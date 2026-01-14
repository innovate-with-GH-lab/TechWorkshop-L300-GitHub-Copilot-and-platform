@description('Environment name (dev, test, prod)')
param environmentName string = 'dev'

@description('Primary location for all resources')
param location string = 'westus3'

@description('Principal ID of the user or service principal for role assignments')
param principalId string = ''

@description('Container Registry name (leave empty for auto-generation)')
param containerRegistryName string = ''

@description('Tags to apply to all resources')
param tags object = {}

// Generate unique resource names
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var namePrefix = 'zava-${environmentName}'

// Resource names
var resourceGroupName = 'rg-${namePrefix}-${location}'
var containerRegistryNameResolved = !empty(containerRegistryName) ? containerRegistryName : 'acr${resourceToken}'
var appServicePlanName = 'plan-${namePrefix}-${resourceToken}'
var webAppName = 'app-${namePrefix}-${resourceToken}'
var logAnalyticsName = 'log-${namePrefix}-${resourceToken}'
var applicationInsightsName = 'ai-${namePrefix}-${resourceToken}'

// Combined tags
var allTags = union({
  Environment: environmentName
  Application: 'ZavaStorefront'
  'azd-env-name': environmentName
}, tags)

var webAppTags = union(allTags, {
  'azd-service-name': 'web'
})

targetScope = 'subscription'

// Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: allTags
}

// Log Analytics Workspace
module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'log-analytics'
  scope: resourceGroup
  params: {
    name: logAnalyticsName
    location: location
    tags: allTags
  }
}

// Application Insights
module applicationInsights 'modules/application-insights.bicep' = {
  name: 'application-insights'
  scope: resourceGroup
  params: {
    name: applicationInsightsName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    tags: allTags
  }
}

// Azure Container Registry
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'container-registry'
  scope: resourceGroup
  params: {
    name: containerRegistryNameResolved
    location: location
    tags: allTags
  }
}

// App Service Plan
module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'app-service-plan'
  scope: resourceGroup
  params: {
    name: appServicePlanName
    location: location
    sku: {
      name: 'B1'
      tier: 'Basic'
    }
    kind: 'linux'
    tags: allTags
  }
}

// Web App
module webApp 'modules/web-app.bicep' = {
  name: 'web-app'
  scope: resourceGroup
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    containerRegistryName: containerRegistryNameResolved
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    applicationInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    tags: webAppTags
  }
}

// Microsoft Foundry - commented out due to deployment issues
// module foundry 'modules/foundry.bicep' = {
//   name: 'foundry'
//   scope: resourceGroup
//   params: {
//     workspaceName: foundryWorkspaceName
//     location: location
//     tags: allTags
//   }
// }

// Role Assignments - ACR Pull for Web App
module roleAssignments 'modules/role-assignments.bicep' = {
  name: 'role-assignments'
  scope: resourceGroup
  params: {
    containerRegistryName: containerRegistryNameResolved
    webAppPrincipalId: webApp.outputs.systemAssignedIdentityPrincipalId
    userPrincipalId: principalId
  }
}

// Outputs
@description('Resource Group Name')
output resourceGroupName string = resourceGroup.name

@description('Container Registry Name')
output containerRegistryName string = containerRegistryNameResolved

@description('Container Registry Login Server')
output containerRegistryLoginServer string = containerRegistry.outputs.loginServer

@description('Web App Name')
output webAppName string = webAppName

@description('Web App URL')
output webAppUrl string = webApp.outputs.webAppUrl

@description('Application Insights Connection String')
@secure()
output applicationInsightsConnectionString string = applicationInsights.outputs.connectionString
