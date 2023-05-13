targetScope = 'managementGroup'
param location string
param PolicyDefID string
param virtualNetworkResourceIDs array
param createPolicyAssignment bool

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
      privateDNSzoneNames: {
        value: [
          '.mysql.database.azure.com'
          '.postgres.database.azure.com'
        ]
      }
    }
    policyDefinitionId: PolicyDefID
  }
}

resource PolicyRemediation 'Microsoft.PolicyInsights/remediations@2021-10-01' = if (createPolicyAssignment) {
  name: 'CreatePrivDNSvnetLink-Remediation'
  properties: {
    policyAssignmentId: PolicyAssignment.id
  }
}

output ManagedIdentityID string = PolicyAssignment.identity.principalId
