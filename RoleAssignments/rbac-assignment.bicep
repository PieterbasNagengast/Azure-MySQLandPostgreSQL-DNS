param VnetName string
param roleDefinitionId string
param ManagedIdentityID string

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: VnetName
}

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(vnet.id)
  scope: vnet
  properties: {
    principalId: ManagedIdentityID
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions',roleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}
