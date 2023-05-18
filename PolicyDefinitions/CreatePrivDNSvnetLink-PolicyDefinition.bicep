targetScope = 'managementGroup'

param PolicyName string = 'Create-PrivDNS-vnet-Link'
param PolicyDisplayName string = 'Deploy VNET Links to Private DNS Zones'
param PolicyDescription string = 'Deploy VNET Links to Private DNS Zones. e.g. for MySQL - Flexible Server and PostgreSQL - Flexible Server'
param PolicyCategory string = 'Private DNS Zones'
param PolicyVersion string = '1.0.0'

var PolicyJSON = loadJsonContent('CreatePrivDNSvnetLink-Policy.json')

resource CreatePrivDNSvnetLink 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: PolicyName
  properties: {
    description: PolicyDescription
    displayName: PolicyDisplayName
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: PolicyCategory
      version: PolicyVersion
    }
    parameters: PolicyJSON.parameters
    policyRule: PolicyJSON.policyRule
  }
}

output PolicyID string = CreatePrivDNSvnetLink.id
output PolicyName string = CreatePrivDNSvnetLink.name
output PolicyDisplayName string = CreatePrivDNSvnetLink.properties.displayName
output PolicyDescription string = CreatePrivDNSvnetLink.properties.description
