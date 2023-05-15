targetScope = 'managementGroup'

param PolicyName string = 'Deny-PrivDNS-zones'
param PolicyDisplayName string = 'Deny the creation of Private DNS Zones except exclusions'
param PolicyDescription string = 'Deny the creation of Private DNS Zones except exclusions like e.g. for MySQL - Flexible Server and PostgreSQL - Flexible Server'
param PolicyCategory string = 'Private DNS Zones'
param PolicyVersion string = '1.0.0'

var PolicyRule = loadJsonContent('DenyPrivDNSzones-PolicyRule.json')
var PolicyParams = loadJsonContent('DenyPrivDNSzones-PolicyParams.json')

resource DenyPrivDNSzones 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
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
    parameters: PolicyParams
    policyRule: PolicyRule
  }
}

output PolicyID string = DenyPrivDNSzones.id
output PolicyName string = DenyPrivDNSzones.name
output PolicyDisplayName string = DenyPrivDNSzones.properties.displayName
output PolicyDescription string = DenyPrivDNSzones.properties.description
