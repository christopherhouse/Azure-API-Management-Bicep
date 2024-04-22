param virtualNetworkName string
param location string
param addressPrefixes array // Array of strings, ie ['10.0.0.0/24', '192.168.0.1']
param subnetConfiguration subnetConfigurationsType
param apimNsgResourceId string
param appGwNsgResourceId string
param keyVaultNsgResourceId string

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

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      {
        name: subnetConfiguration.appServiceOutboundSubnet.name
        properties: {
          addressPrefix: subnetConfiguration.appServiceOutboundSubnet.addressPrefix
          delegations: subnetConfiguration.appServiceOutboundSubnet.delegation == 'none' ? [] : [
            {
              name: subnetConfiguration.appServiceOutboundSubnet.delegation
              properties: {
                serviceName: subnetConfiguration.appServiceOutboundSubnet.delegation
              }
            }
          ]
        }
      }
      {
        name: subnetConfiguration.appServiceInboundSubnet.name
        properties: {
          addressPrefix: subnetConfiguration.appServiceInboundSubnet.addressPrefix
          delegations: subnetConfiguration.appServiceInboundSubnet.delegation == 'none' ? [] : [
            {
              name: subnetConfiguration.appServiceInboundSubnet.delegation
              properties: {
                serviceName: subnetConfiguration.appServiceInboundSubnet.delegation
              }
            }
          ]
        }
      }
      {
        name: subnetConfiguration.keyVaultSubnet.name
        properties: {
          addressPrefix: subnetConfiguration.keyVaultSubnet.addressPrefix
          delegations: subnetConfiguration.keyVaultSubnet.delegation == 'none' ? [] : [
            {
              name: subnetConfiguration.keyVaultSubnet.delegation
              properties: {
                serviceName: subnetConfiguration.keyVaultSubnet.delegation
  
              }
            }
          ]
          networkSecurityGroup: {
            id: keyVaultNsgResourceId
          }
        }
      }
      {
        name: subnetConfiguration.apimSubnet.name
        properties: {
          addressPrefix: subnetConfiguration.apimSubnet.addressPrefix
          delegations: subnetConfiguration.apimSubnet.delegation == 'none' ? [] : [
            {
              name: subnetConfiguration.apimSubnet.delegation
              properties: {
                serviceName: subnetConfiguration.apimSubnet.delegation
              }
            }
          ]
          networkSecurityGroup: {
            id: apimNsgResourceId
          }
        }
      }
      {
        name: subnetConfiguration.appGwSubnet.name
        properties: {
          addressPrefix: subnetConfiguration.appGwSubnet.addressPrefix
          delegations: subnetConfiguration.appGwSubnet.delegation == 'none' ? [] : [
            {
              name: subnetConfiguration.appGwSubnet.delegation
              properties: {
                serviceName: subnetConfiguration.appGwSubnet.delegation
              }
            }
          ]
          networkSecurityGroup: {
            id: appGwNsgResourceId
          }
        }
      }
    ]
  }
}

output id string = vnet.id
output name string = vnet.name
output kvSubnetId string = vnet.properties.subnets[2].id
