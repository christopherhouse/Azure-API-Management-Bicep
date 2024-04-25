using '../02-main.bicep'
param workloadName = 'cmhapim'
param environmentSuffix = 'loc'
param location = 'eastus2'
param vnetName = 'cmhapim-loc-vnet'
param apimSubnetName = 'apim'
param logAnalyticsWorkspaceName = 'cmhapim-loc-laws'
param keyVaultName = 'cmhapim-loc-kv'
param apimPublisherEmailAddress = 'fake.email@yyzz.ca'
param apimPublisherOrganizationName = 'Test Org'
param apimSkuName = 'Developer'
param apimSkuCapacity = 1
param apimVnetIntegrationMode = 'Internal'
param appGatewayMinInstances = 1
param appGatewayMaxInstances = 10
param appGatewaySkuName = 'Standard_v2'
param appGatewayTslCertSecretName = 'api-chrishou-se'
param appGwSubnetName = 'app-gateway'
param appGatewayHostName = 'api.chrishou.se'
param appGatewayPrivateIp = '10.1.0.50'
param apiCenterWorkspaceName = 'Default'
param tags = {
  CostCenter: '12345'
  Project: 'cmhapim'
  Owner: 'Chris House'
}
