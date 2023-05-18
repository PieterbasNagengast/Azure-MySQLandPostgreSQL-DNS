targetScope = 'managementGroup'
param location string
param PolicyDefID string
param PolicyName string
param PolicyDisplayName string
param PolicyDescription string
param virtualNetworkResourceID string
param privateDNSzoneNames array
param createPolicyAssignment bool
param roleDefinitionId string

@allowed([
  'disabled'
  'deployIfNotExists'
])
param PolicyEffect string = 'deployIfNotExists'

resource PolicyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: PolicyName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: PolicyDisplayName
    description: PolicyDescription
    parameters: {
      effect: {
        value: PolicyEffect
      }
      virtualNetworkResourceId: {
        value: virtualNetworkResourceID
      }
      privateDNSzoneNames: {
        value: privateDNSzoneNames
      }
    }
    policyDefinitionId: PolicyDefID
  }
}

// Deploy RBAC Assignment. Assign role to the Managed Identity used by the Policy Assignment for remediation
resource rbac1 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(PolicyAssignment.id)
  properties: {
    principalId: PolicyAssignment.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}

// Deploy RBAC Assignment. Assign role to the Managed Identity used by the Policy Assignment for remediation
module rbac2 'CreatePrivDNSvnetLink-RoleAssignment.bicep' = {
  name: 'Deploy-rbac-policyAssign-${location}'
  scope: resourceGroup(split(virtualNetworkResourceID, '/')[2], split(virtualNetworkResourceID, '/')[4])
  params: {
    ManagedIdentityID: PolicyAssignment.identity.principalId
    roleDefinitionId: roleDefinitionId
    VnetName: split(virtualNetworkResourceID, '/')[8]
  }
}

resource PolicyRemediation 'Microsoft.PolicyInsights/remediations@2021-10-01' = if (createPolicyAssignment) {
  name: PolicyDisplayName
  properties: {
    policyAssignmentId: PolicyAssignment.id
  }
  dependsOn: [
    rbac1
    rbac2
  ]
}

output ManagedIdentityID string = PolicyAssignment.identity.principalId
