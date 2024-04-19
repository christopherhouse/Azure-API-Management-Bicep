param workloadName string
param environmentSuffix string
param location string
param vnetName string
param apimSubnetName string
param appGwSubnetName string
param logAnalyticsWorkspaceName string
param keyVaultName string
param apimPublisherEmailAddress string
param apimPublisherOrganizationName string
@allowed(['Developer', 'Premium']) // APIM module assumes vnet integration, so only allow vnet enabled SKUs
param apimSkuName string
param apimSkuCapacity int
@allowed(['Internal', 'External'])
param apimVnetIntegrationMode string
param appGatewayMinInstances int
param appGatewayMaxInstances int
@allowed(['WAF_v2', 'Standard_v2'])
param appGatewaySkuName string
param appGatewayTslCertSecretName string
param deploymentId string = substring(newGuid(), 0, 8)

// APIM
var apimName = '${workloadName}-${environmentSuffix}-apim'
var apimDeploymentName = '${apimName}-${deploymentId}'

var apimPipName = '${apimName}-pip'
var apimPipDeploymentName = '${apimPipName}-${deploymentId}'

// APIM only allows 1 scale unit for Developer, so overrite apimSkuCapacity if Developer SKU and force capacity = 1
var apimCapacity = apimSkuName == 'Developer' ? 1 : apimSkuCapacity

var apimUamiName = '${apimName}-uami'
var apimUamiDeploymentName = '${apimUamiName}-${deploymentId}'

// App Gatway
var appGwName = '${workloadName}-${environmentSuffix}-appgw'
var appGwDeploymentName = '${appGwName}-${deploymentId}'

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
  scope: resourceGroup()
}

resource apimSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: apimSubnetName
  parent: vnet
}

resource laws 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup()
}

module apimUami './modules/managedIdentity/userAssignedManagedIdentity.bicep' = {
  name: apimUamiDeploymentName
  params: {
    location: location
    managedIdentityName: apimUamiName 
  }
}

module apimPip './modules/publicIpAddress/publicIpAddress.bicep' = {
  name: apimPipDeploymentName
  params: {
    location: location
    publicIpAddressName: apimPipName
    logAnalyticsWorkspaceId: laws.id
  }
}

module apim './modules/apiManagement/apiManagementService.bicep' = {
  name: apimDeploymentName
  params: {
    location: location
    apiManagementServiceName: apimName
    deploymentId: deploymentId
    keyVaulName: keyVaultName
    logAnalyticsWorkspaceId: laws.id
    publicIpResourceId: apimPip.outputs.id
    publisherEmailAddress: apimPublisherEmailAddress
    publisherOrganizationName: apimPublisherOrganizationName
    skuCapacity: apimCapacity
    skuName: apimSkuName
    userAssignedManagedIdentityPrincipalId: apimUami.outputs.principalId
    userAssignedManagedIdentityResourceId: apimUami.outputs.id
    vnetIntegrationMode: apimVnetIntegrationMode
    vnetResourceId: vnet.id
    vnetSubnetResourceId: apimSubnet.id
  }
}

module appGw './modules/applicationGateway/applicationGateway.bicep' = {
  name: appGwDeploymentName
  params: {
    location: location
    appGatewayName: appGwName
    appGatewaySubnetName: appGwSubnetName
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceId: laws.id
    minInstances: appGatewayMinInstances
    maxInstances: appGatewayMaxInstances
    skuName: appGatewaySkuName
    vnetName: vnetName
    apimBackendHostName: apim.outputs.hostName
    apimSslCertKeyVaultSecretName: appGatewayTslCertSecretName
  }
}
