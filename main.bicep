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

// Deploy Policy Definition
module CreatePrivDNSvnetLink_Definition 'PolicyDefinitions/CreatePrivDNSvnetLink-PolicyDefinition.bicep' = {
  name: 'Deploy-CreatePrivDNSvnetLink-policyDef-${location}'
}

// Deploy Policy Assignment
module CreatePrivDNSvnetLink_Assignment 'PolicyAssignments/Assignment-CreatePrivDNSvnetLink.bicep' = {
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

output PolicyDefID string = CreatePrivDNSvnetLink_Definition.outputs.PolicyID
output ManagedIdentityID string = CreatePrivDNSvnetLink_Assignment.outputs.ManagedIdentityID
