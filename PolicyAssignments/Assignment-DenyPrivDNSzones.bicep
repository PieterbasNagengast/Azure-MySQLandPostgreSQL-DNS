targetScope = 'managementGroup'
param location string
param PolicyDefID string
param PolicyName string
param PolicyDisplayName string
param PolicyDescription string
param privateDNSzoneNames array

@allowed([
  'Deny'
  'Audit'
  'Disabled'
])
param PolicyEffect string = 'Deny'

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
      ExcludeDNSzones: {
        value: privateDNSzoneNames
      }
    }
    policyDefinitionId: PolicyDefID
  }
}
