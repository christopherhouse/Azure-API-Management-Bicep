@description('The name of the Public IP Address resource to be created')
param publicIpAddressName string

@description('The DNS label for the Public IP Address.  Defaults to resource name')
param dnsLabel string = publicIpAddressName

@description('The region where the Public IP Address will be created')
param location string

@description('A flag indicating whether the IP address will be zone redundant')
param zoneRedundant bool = false

var zones = zoneRedundant ? ['1', '2', '3'] : []

resource pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    dnsSettings: {
      domainNameLabel: dnsLabel
    }
    publicIPAllocationMethod: 'Static'
  }
  zones: zones
}

output id string = pip.id
output ip string = pip.properties.ipAddress
