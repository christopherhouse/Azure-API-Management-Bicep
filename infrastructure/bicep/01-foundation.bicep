param workloadName string
param environmentSuffix string
param location string
param addressPrefixes array
param subnetConfigurations subnetConfigurationsType
param logAnalyticsRetentionDays int
param deploymentId string = substring(newGuid(), 0, 8)

@export()
type subnetConfigurationType = {
  name: string
  addressPrefix: string
  delegation: string
}

@export()
type subnetConfigurationsType = {
  appServiceOutboundSubnet: subnetConfigurationType
  appServiceInboundSubnet: subnetConfigurationType
  keyVaultSubnet: subnetConfigurationType
  apimSubnet: subnetConfigurationType
  appGwSubnet: subnetConfigurationType
}

// vnet
var vnetName = '${workloadName}-${environmentSuffix}-vnet'
var vnetDeploymentName = '${vnetName}-${deploymentId}'

// subnets
var appServiceOutboundSubnetDeploymentName = '${vnetName}-${subnetConfigurations.appServiceOutboundSubnet.name}-${deploymentId}'
var appServiceInboundSubnetDeploymentName = '${vnetName}-${subnetConfigurations.appServiceInboundSubnet.name}-${deploymentId}'
var keyVaultSubnetDeploymentName = '${vnetName}-${subnetConfigurations.keyVaultSubnet.name}-${deploymentId}'
var apimSubnetDeploymentName = '${vnetName}-${subnetConfigurations.apimSubnet.name}-${deploymentId}'
var appGwSubnetDeploymentName = '${vnetName}-${subnetConfigurations.appGwSubnet.name}-${deploymentId}'

// Key Vault
var keyVaultName = '${workloadName}-${environmentSuffix}-kv'
var keyVaultDeploymentName = '${keyVaultName}-${deploymentId}'

// Log Analytics
var logAnalyticsWorkspaceName = '${workloadName}-${environmentSuffix}-laws'
var logAnalyticsWorkspaceDeploymentName = '${logAnalyticsWorkspaceName}-${deploymentId}'

// App Insights
var appInsightsName = '${workloadName}-${environmentSuffix}-ai'
var appInsightsDeploymentName = '${appInsightsName}-${deploymentId}'

module vnet './modules/virtualNetwork/virtualNetwork.bicep' = {
  name: vnetDeploymentName
  params: {
    location: location
    addressPrefixes: addressPrefixes
    virtualNetworkName: vnetName
    subnetConfiguration: subnetConfigurations
  }
}

module kv './modules/keyVault/privateKeyVault.bicep' = {
  name: keyVaultDeploymentName
  params: {
    location: location
    deploymentId: deploymentId
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceResourceId: laws.outputs.id 
    servicesSubnetResourceId: vnet.outputs.kvSubnetId
    vnetName: vnet.outputs.name
  }
}

module laws './modules/observability/logAnalyticsWorkspace.bicep' = {
  name: logAnalyticsWorkspaceDeploymentName
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    retentionInDays: logAnalyticsRetentionDays
  }
}

module ai './modules/observability/applicationInsights.bicep' = {
  name: appInsightsDeploymentName
  params: {
    location: location
    appInsightsName: appInsightsName
    buildId: deploymentId
    keyVaultName: kv.outputs.name
    logAnalyticsWorkspaceId: laws.outputs.id
  }
}
