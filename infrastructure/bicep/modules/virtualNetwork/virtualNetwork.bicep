param virtualNetworkName string
param location string
param addressPrefixes array // Array of strings, ie ['10.0.0.0/24', '192.168.0.1']

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
  }
}

output id string = vnet.id
output name string = vnet.name
