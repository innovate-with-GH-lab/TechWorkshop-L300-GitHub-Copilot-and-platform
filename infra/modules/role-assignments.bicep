@description('Container Registry name')
param containerRegistryName string

@description('Web App Principal ID')
param webAppPrincipalId string

@description('User Principal ID for additional permissions')
param userPrincipalId string = ''

// ACR Pull role definition ID
var acrPullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

// Get reference to existing Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
}

// Assign ACR Pull role to Web App managed identity
resource webAppAcrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: containerRegistry
  name: guid(containerRegistry.id, webAppPrincipalId, acrPullRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
    principalId: webAppPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Assign ACR Pull role to user (if provided)
resource userAcrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userPrincipalId)) {
  scope: containerRegistry
  name: guid(containerRegistry.id, userPrincipalId, acrPullRoleId, 'user')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
    principalId: userPrincipalId
    principalType: 'User'
  }
}

@description('ACR Pull role assignment ID for Web App')
output webAppRoleAssignmentId string = webAppAcrPullAssignment.id

@description('ACR Pull role assignment ID for User')
output userRoleAssignmentId string = !empty(userPrincipalId) ? userAcrPullAssignment.id : ''
