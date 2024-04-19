@description('The name of the application gateway to create')
param appGatewayName string

@description('The Azure region where the application gateway will be created')
param location string

@description('The SKU of the application gateway')
@allowed(['Standard_v2', 'WAF_v2'])
param skuName string

@description('The minimum number of instances for the application gateway')
param minInstances int = 0

@description('The maximum number of instances for the application gateway')
param maxInstances int

@description('The name of the key vault where the SSL certificate is stored')
param keyVaultName string

@description('The hostname of the backend web app that application gateway will expose')
param apimBackendHostName string

@description('The name of the secret in the key vault that contains the SSL certificate')
param apimSslCertKeyVaultSecretName string

@description('The name of the virtual network where the application gateway will be deployed')
param vnetName string

@description('The name of the subnet where the application gateway will be deployed')
param appGatewaySubnetName string

@description('The name of the web app that the application gateway will expose')
param logAnalyticsWorkspaceId string

@description('Whether to enable zone redundancy for the application gateway')
param enableZoneRedundancy bool = false

var zones = enableZoneRedundancy ? ['1', '2', '3'] : []

var keyVaultSecretId = 'https://${keyVaultName}${environment().suffixes.keyvaultDns}/secrets/${apimSslCertKeyVaultSecretName}'
var publicIpName = '${appGatewayName}-pip'

var uamiName = '${appGatewayName}-uami'
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'

resource kvSecretUser 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: keyVaultSecretsUserRoleId
  scope: subscription()
}

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: uamiName
  location: location
}

resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(uami.id, kv.id, kvSecretUser.id)
  scope: kv
  properties: {
    principalId: uami.properties.principalId
    roleDefinitionId: kvSecretUser.id
    principalType: 'ServicePrincipal'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: vnetName
  scope: resourceGroup()
}

resource appGwSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: appGatewaySubnetName
  parent: vnet
}

resource appGwPip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name:publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: publicIpName
    }
  }
  zones: zones
}

var appGatewayIpConfigName = 'appGatewayIpConfig'
var sslCertNmae = 'api-management'
var frontEndConfigName = 'appGwPublicFrontendIpIPv4'
var apimProbeName = 'apimProbe'
var frontEndPortName = 'port_443'
var backendPoolName = 'apimBackendPool'
var backendHttpSettingsName = 'apimBackendSettings'
var httpListenerName = 'publicHttps'
var apimRoutingRuleName = 'apimRule'

resource appGw 'Microsoft.Network/applicationGateways@2023-09-01' = {
  name: appGatewayName
  location: location
  zones: zones
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
  properties: {
    sku: {
      name: skuName
      tier: skuName
    }
    gatewayIPConfigurations: [
      {
        name: appGatewayIpConfigName
        id: resourceId('Microsoft.Network/applicationGateways/gatewayIPConfigurations', appGatewayName, appGatewayIpConfigName)
        properties: {
          subnet: {
            id: appGwSubnet.id
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: sslCertNmae
        id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGatewayName, sslCertNmae)
        properties: {
          keyVaultSecretId: keyVaultSecretId
        }
      }
    ]
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: frontEndConfigName
        id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, frontEndConfigName)
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: appGwPip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: frontEndPortName
        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, frontEndPortName)
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolName
        id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, backendPoolName)
        properties: {
          backendAddresses: [
            {
              fqdn: apimBackendHostName
            }
          ]
        }
      }
    ]
    loadDistributionPolicies: []
    backendHttpSettingsCollection: [
      {
        name: backendHttpSettingsName
        id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, backendHttpSettingsName)
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          hostName: apimBackendHostName
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, apimProbeName)
          }
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: httpListenerName
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, httpListenerName)
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, frontEndConfigName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, frontEndPortName)
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGatewayName, sslCertNmae)
          }
          hostNames: []
          requireServerNameIndication: false
          customErrorConfigurations: []
        }
      }
    ]
    listeners: []
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: apimRoutingRuleName
        id: resourceId('Microsoft.Network/applicationGateways/requestRoutingRules', appGatewayName, apimRoutingRuleName)
        properties: {
          ruleType: 'Basic'
          priority: 1
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, httpListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, backendHttpSettingsName)
          }
        }
      }
    ]
    routingRules: []
    probes: [
      {
        name: apimProbeName
        id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, apimProbeName)
        properties: {
          protocol: 'Https'
          path: '/status-0123456789abcdef'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {}
        }
      }
    ]
    rewriteRuleSets: []
    redirectConfigurations: []
    privateLinkConfigurations: []
    enableHttp2: true
    autoscaleConfiguration: {
      minCapacity: minInstances
      maxCapacity: maxInstances
    }
  }
}

resource diags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'laws'
  scope: appGw
  properties: {
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspaceId
  }
}

resource pipDiags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'pipDiags'
  scope: appGwPip
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspaceId
  }
}
