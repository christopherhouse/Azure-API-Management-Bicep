param workloadName string
param environmentSuffix string
param location string
param vnetName string
param apimSubnetName string
param appGwSubnetName string
param logAnalyticsWorkspaceName string
param keyVaultName string
param provisionApimPublicIp bool
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
param appGatewayHostName string
param appGatewayPrivateIp string
param apiCenterWorkspaceName string
@allowed(['Free'])
param apiCenterSku string
param apiCenterLocation string
param tags object = {}
param deploymentId string = substring(newGuid(), 0, 8)

// APIM
var apimName = '${workloadName}-${environmentSuffix}-apim'
var apimDeploymentName = '${apimName}-${deploymentId}'

// APIM only allows 1 scale unit for Developer, so overrite apimSkuCapacity if Developer SKU and force capacity = 1
var apimCapacity = apimSkuName == 'Developer' ? 1 : apimSkuCapacity

var apimUamiName = '${apimName}-uami'
var apimUamiDeploymentName = '${apimUamiName}-${deploymentId}'

// App Gatway
var appGwName = '${workloadName}-${environmentSuffix}-appgw'
var appGwDeploymentName = '${appGwName}-${deploymentId}'

// API Center
var apiCenterName = '${workloadName}-${environmentSuffix}-apic'
var apiCenterDeploymentName = '${apiCenterName}-${deploymentId}'

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
    tags: tags
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
    publisherEmailAddress: apimPublisherEmailAddress
    publisherOrganizationName: apimPublisherOrganizationName
    skuCapacity: apimCapacity
    skuName: apimSkuName
    userAssignedManagedIdentityPrincipalId: apimUami.outputs.principalId
    userAssignedManagedIdentityResourceId: apimUami.outputs.id
    vnetIntegrationMode: apimVnetIntegrationMode
    vnetResourceId: vnet.id
    vnetSubnetResourceId: apimSubnet.id
    provisionPublicIp: provisionApimPublicIp
    tags: tags
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
    appGatewayHostName: appGatewayHostName
    appGatewayPrivateIp: appGatewayPrivateIp
    tags: tags
  }
}

module apiCenter './modules/apiCenter/apiCenter.bicep' = {
  name: apiCenterDeploymentName
  params: {
    location: apiCenterLocation
    apiCenterName: apiCenterName
    apiCenterWorkspaceName: apiCenterWorkspaceName
    sku: apiCenterSku
    tags: tags
  }
}
