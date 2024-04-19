@description('The name of the Key Vault to be created')
param keyVaultName string

@description('The region where the Key Vault will be created')
param location string

@description('The resource id of the log analytics workspace to send logs to')
param logAnalyticsWorkspaceResourceId string

@description('The name of the virtual network to link the private DNS zone to')
param vnetName string

@description('The resource id of the subnet to link the private endpoint to')
param servicesSubnetResourceId string

@description('Deployment identifier, used to ensure uniqueness of deployment names')
param deploymentId string

var kvDeploymentName = '${keyVaultName}-private-kv-${deploymentId}'

var kvDnsZoneName = 'privatelink.vaultcore.azure.net'
var kvDnsZoneDeploymentName = '${kvDnsZoneName}-${deploymentId}'

var kvPeName = '${keyVaultName}-pe'
var kvPeDeploymentName = '${kvPeName}-${deploymentId}'

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
  scope: resourceGroup()
}

module kv './keyVault.bicep' = {
  name: kvDeploymentName
  params: {
    location: location
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}

module kvDns '../dns/privateDnsZone.bicep' = {
  name: kvDnsZoneDeploymentName
  params: {
    vnetResourceId: vnet.id
    zoneName: kvDnsZoneName
  }
}

module kvPe '../privateEndpoint/privateEndpoint.bicep' = {
  name: kvPeDeploymentName
  params: {
    location: location
    dnsZoneId: kvDns.outputs.id
    groupId: 'vault'
    privateEndpointName: kvPeName
    subnetId: servicesSubnetResourceId
    targetResourceId: kv.outputs.id
  }
}

output id string = kv.outputs.id
output name string = kv.outputs.name
