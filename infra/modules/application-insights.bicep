@description('Application Insights name')
param name string

@description('Location for Application Insights')
param location string = resourceGroup().location

@description('Log Analytics Workspace ID')
param logAnalyticsWorkspaceId string

@description('Application type')
param applicationType string = 'web'

@description('Ingestion mode')
param ingestionMode string = 'LogAnalytics'

@description('Tags to apply to the resource')
param tags object = {}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: applicationType
    Flow_Type: 'Redfield'
    Request_Source: 'rest'
    IngestionMode: ingestionMode
    WorkspaceResourceId: logAnalyticsWorkspaceId
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('Application Insights Instrumentation Key')
@secure()
output instrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('Application Insights Connection String')
@secure()
output connectionString string = applicationInsights.properties.ConnectionString

@description('Application Insights Resource ID')
output resourceId string = applicationInsights.id
