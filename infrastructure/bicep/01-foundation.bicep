param workloadName string
param environmentSuffix string
param location string
param addressPrefixes array
param subnetConfigurations subnetConfigurationsType
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

module vnet './modules/virtualNetwork/virtualNetwork.bicep' = {
  name: vnetDeploymentName
  params: {
    location: location
    addressPrefixes: addressPrefixes
    virtualNetworkName: vnetName
  }
}

// For Subnets, we need to ensure the deployment is serialized, so setup manual
// dependencies to ensure subnets don't deploy in parallel since that leads to an
// operation conflict during deployment :()
module appSvcInSubnet './modules/virtualNetwork/subnet.bicep' = {
  name: appServiceInboundSubnetDeploymentName
  params: {
    addressPrefix: subnetConfigurations.appServiceInboundSubnet.addressPrefix
    subnetName: subnetConfigurations.appServiceInboundSubnet.name
    vnetName: vnet.outputs.name
  }
}

module appSvcOutSubnet './modules/virtualNetwork/subnet.bicep' = {
  name: appServiceOutboundSubnetDeploymentName
  params: {
    addressPrefix: subnetConfigurations.appServiceOutboundSubnet.addressPrefix
    subnetName: subnetConfigurations.appServiceOutboundSubnet.name
    vnetName: vnet.outputs.name
  }
  dependsOn: [
    appSvcInSubnet
  ]
}

module keyVaultSubnet './modules/virtualNetwork/subnet.bicep' = {
  name: keyVaultSubnetDeploymentName
  params: {
    addressPrefix: subnetConfigurations.keyVaultSubnet.addressPrefix
    subnetName: subnetConfigurations.keyVaultSubnet.name
    vnetName: vnet.outputs.name
  }
  dependsOn: [
    appSvcOutSubnet
  ]
}

module apimSubnet './modules/virtualNetwork/subnet.bicep' = {
  name: apimSubnetDeploymentName
  params: {
    addressPrefix: subnetConfigurations.apimSubnet.addressPrefix
    subnetName: subnetConfigurations.apimSubnet.name
    vnetName: vnet.outputs.name
  }
  dependsOn: [
    keyVaultSubnet
  ]
}

module appGwSubnet './modules/virtualNetwork/subnet.bicep' = {
  name: appGwSubnetDeploymentName
  params: {
    addressPrefix: subnetConfigurations.appGwSubnet.addressPrefix
    subnetName: subnetConfigurations.appGwSubnet.name
    vnetName: vnet.outputs.name
  }
  dependsOn: [
    apimSubnet
  ]
}
