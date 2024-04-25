param workloadName string
param environmentSuffix string
param location string
param addressPrefixes array
param subnetConfigurations subnetConfigurationsType
param logAnalyticsRetentionDays int
param deploymentId string = substring(newGuid(), 0, 8)
@description('The tags to associate with the API Center resource')
param tags object = {}

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

// NSGs
var apimNsgName = '${workloadName}-${environmentSuffix}-apim-nsg'
var appGwNsgName = '${workloadName}-${environmentSuffix}-appgw-nsg'
var keyVaultNsgName = '${workloadName}-${environmentSuffix}-kv-nsg'
var apimNsgDeploymentName = '${apimNsgName}-${deploymentId}'
var appGwNsgDeploymentName = '${appGwNsgName}-${deploymentId}'
var keyVaultNsgDeploymentName = '${keyVaultNsgName}-${deploymentId}'

// Key Vault
var keyVaultName = '${workloadName}-${environmentSuffix}-kv'
var keyVaultDeploymentName = '${keyVaultName}-${deploymentId}'

// Log Analytics
var logAnalyticsWorkspaceName = '${workloadName}-${environmentSuffix}-laws'
var logAnalyticsWorkspaceDeploymentName = '${logAnalyticsWorkspaceName}-${deploymentId}'

// App Insights
var appInsightsName = '${workloadName}-${environmentSuffix}-ai'
var appInsightsDeploymentName = '${appInsightsName}-${deploymentId}'

module apimNsg './modules/networkSecurityGroup/apimNetworkSecurityGroup.bicep' = {
  name: apimNsgDeploymentName
  params: {
    location: location
    logAnalyticsWorkspaceResourceId: laws.outputs.id
    nsgName: apimNsgName
    apimSubnetRange: subnetConfigurations.apimSubnet.addressPrefix
    appGatewaySubnetRange: subnetConfigurations.appGwSubnet.addressPrefix
  }
}

module appGwNsg './modules/networkSecurityGroup/applicationGatewayNetworkSecurityGroup.bicep' = {
  name: appGwNsgDeploymentName
  params: {
    location: location
    appGatewaySubnetAddressSpace: subnetConfigurations.appGwSubnet.addressPrefix
    logAnalyticsWorkspaceResourceId: laws.outputs.id
    networkSecurityGroupName: appGwNsgName
  }
}

module kvNsg './modules/networkSecurityGroup/keyVaultNetworkSecurityGroup.bicep' = {
  name: keyVaultNsgDeploymentName
  params: {
    location: location
    apimSubnetRange: subnetConfigurations.apimSubnet.addressPrefix
    appGatewaySubnetRange: subnetConfigurations.appGwSubnet.addressPrefix
    keyVaultSubnetRange: subnetConfigurations.keyVaultSubnet.addressPrefix
    logAnalyticsWorkspaceId: laws.outputs.id
    networkSecurityGroupName: keyVaultNsgName
  }
}

module vnet './modules/virtualNetwork/virtualNetwork.bicep' = {
  name: vnetDeploymentName
  params: {
    location: location
    addressPrefixes: addressPrefixes
    virtualNetworkName: vnetName
    subnetConfiguration: subnetConfigurations
    apimNsgResourceId: apimNsg.outputs.id
    appGwNsgResourceId: appGwNsg.outputs.id
    keyVaultNsgResourceId: kvNsg.outputs.id
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
    tags: tags
  }
}

module laws './modules/logAnalytics/logAnalyticsWorkspace.bicep' = {
  name: logAnalyticsWorkspaceDeploymentName
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    retentionInDays: logAnalyticsRetentionDays
    tags: tags
  }
}

module ai './modules/applicationInsights/applicationInsights.bicep' = {
  name: appInsightsDeploymentName
  params: {
    location: location
    appInsightsName: appInsightsName
    buildId: deploymentId
    keyVaultName: kv.outputs.name
    logAnalyticsWorkspaceId: laws.outputs.id
    tags: tags
  }
}
