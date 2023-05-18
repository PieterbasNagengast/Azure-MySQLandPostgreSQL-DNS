targetScope = 'managementGroup'

@description('Location for Policy Assignment')
param location string = deployment().location

@description('Management group ID for Policy Assignment')
param ManagementGroupID_PolicyAssignment string

@description('Virtual Network resource ID to be linked to the private DNS zone')
param virtualNetworkResourceID string

@description('Array of private DNS zone names to be linked to the virtual network. Use * as wildcard for subdomain matching. e.g. *.mysql.database.azure.com')
param privateDNSzoneNames array = [
  '*.mysql.database.azure.com'
  '*.postgres.database.azure.com'
]

@description('Create Policy Remediation Task')
param createPolicyRemediationTask bool = true

// Azure Role Definition of Private DNS Zone Contributor (b12aa53e-6015-4669-85d0-8515ebb3ae7f)
var roleDefId = 'b12aa53e-6015-4669-85d0-8515ebb3ae7f'

// Deploy Policy Definitions:
// Deploy Policy Definition: Create Priv DNS vnet links
module CreatePrivDNSvnetLink_Definition 'PolicyDefinitions/CreatePrivDNSvnetLink-PolicyDefinition.bicep' = {
  name: 'Deploy-CreatePrivDNSvnetLink-policyDef-${location}'
}

// Deploy Policy Definition: Deny creation of Private DNS Zones except exclusions
module DenyPrivDNSZone_Definition 'PolicyDefinitions/DenyPrivDNSzones-PolicyDefinition.bicep' = {
  name: 'Deploy-DenyPrivDNSZone_Definition-policyDef-${location}'
}

// Deploy Policy Assignments:
// Deploy Policy Assignment: Create Priv DNS vnet links
module CreatePrivDNSvnetLink_Assignment 'PolicyAssignments/CreatePrivDNSvnetLink-PolicyAssignment.bicep' = {
  name: 'Deploy-CreatePrivDNSvnetLink-policyAssign-${location}'
  scope: managementGroup(ManagementGroupID_PolicyAssignment)
  params: {
    location: location
    PolicyDefID: CreatePrivDNSvnetLink_Definition.outputs.PolicyID
    virtualNetworkResourceID: virtualNetworkResourceID
    privateDNSzoneNames: privateDNSzoneNames
    createPolicyAssignment: createPolicyRemediationTask
    PolicyDescription: CreatePrivDNSvnetLink_Definition.outputs.PolicyDescription
    PolicyDisplayName: CreatePrivDNSvnetLink_Definition.outputs.PolicyDisplayName
    PolicyName: CreatePrivDNSvnetLink_Definition.outputs.PolicyName
    roleDefinitionId: roleDefId
  }
}

// Deploy Policy Assignment: Deny creation of Private DNS Zones except exclusions
module DenyPrivDNSZone_Definition_Assignment 'PolicyAssignments/DenyPrivDNSzones-PolicyAssignment.bicep' = {
  name: 'Deploy-DenyPrivDNSZones-policyAssign-${location}'
  scope: managementGroup(ManagementGroupID_PolicyAssignment)
  params: {
    location: location
    PolicyDefID: DenyPrivDNSZone_Definition.outputs.PolicyID
    PolicyDescription: DenyPrivDNSZone_Definition.outputs.PolicyDescription
    PolicyDisplayName: DenyPrivDNSZone_Definition.outputs.PolicyDisplayName
    PolicyName: DenyPrivDNSZone_Definition.outputs.PolicyName
    privateDNSzoneNames: privateDNSzoneNames
  }
}

output PolicyDefID string = CreatePrivDNSvnetLink_Definition.outputs.PolicyID
output ManagedIdentityID string = CreatePrivDNSvnetLink_Assignment.outputs.ManagedIdentityID
