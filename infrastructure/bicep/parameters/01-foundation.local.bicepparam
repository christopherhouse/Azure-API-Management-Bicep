using '../01-foundation.bicep'
param workloadName = 'cmhapim'
param environmentSuffix = 'local'
param location = 'eastus2'
param addressPrefixes = ['10.1.0.0/24']
param subnetConfigurations = {
  apimSubnet: {
    name: 'apim'
    addressPrefix: '10.1.0.128/26'
    delegation: 'none'
  }
  appGwSubnet: {
    name: 'app-gateway'
    addressPrefix: '10.1.0.0/26'
    delegation: 'none'
  }
  appServiceInboundSubnet: {
    name: 'app-service-inbound'
    addressPrefix: '10.1.0.224/28'
    delegation: 'none'
  }
  appServiceOutboundSubnet: {
    name: 'app-service-outbound'
    addressPrefix: '10.1.0.64/26'
    delegation: 'none'
  }
  keyVaultSubnet: {
    name: 'key-vault'
    addressPrefix: '10.1.0.240/28'
    delegation: 'none'
  }
}
param logAnalyticsRetentionDays = 90
