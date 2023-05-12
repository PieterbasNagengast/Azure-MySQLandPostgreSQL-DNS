targetScope = 'managementGroup'
param location string
param PolicyDefID string
param virtualNetworkResourceIDs array

resource PolicyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'CreatePrivDNSvnetLink'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'CreatePrivDNSvnetLink-Assignment-displayname'
    description: 'CreatePrivDNSvnetLink-Assignment-description'
    parameters: {
      virtualNetworkResourceId: {
        value: virtualNetworkResourceIDs
      }
      registrationEnabled: {
        value: false
      }
    }
    policyDefinitionId: PolicyDefID
  }
}

output ManagedIdentityID string = PolicyAssignment.identity.principalId
