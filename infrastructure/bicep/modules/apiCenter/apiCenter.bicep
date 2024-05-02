@description('The name of the API Center resource to create')
param apiCenterName string

@description('The Azure resource where the API Center resource will be created.  NOT CURRENTLY USED, REGION IS HARD-CODED')
param location string

@description('The name of the API Center workspace to create')
param apiCenterWorkspaceName string

@allowed(['Free'])
param sku string

@description('The tags to associate with the API Center resource')
param tags object = {}

resource apiCenter 'Microsoft.ApiCenter/services@2024-03-01' = {
  name: apiCenterName
  tags: tags
  location: location
  #disable-next-line BCP187 // Probably will need to be updated as API Center moves to GA
  sku: {
    name: sku
  }
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
