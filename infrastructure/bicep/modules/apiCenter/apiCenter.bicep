param apiCenterName string
param location string
param apiCenterWorkspaceName string

resource apiCenter 'Microsoft.ApiCenter/services@2024-03-01' = {
  name: apiCenterName
  location: 'eastus' // Hardcoded to eastus for now since API Center is available in limited environments
  properties: {
  }
}

resource workspace 'Microsoft.ApiCenter/services/workspaces@2024-03-01' = {
  name: apiCenterWorkspaceName
  parent: apiCenter
  properties: {
    title: apiCenterWorkspaceName
    description: '${apiCenterWorkspaceName} workspace'
  }
}
