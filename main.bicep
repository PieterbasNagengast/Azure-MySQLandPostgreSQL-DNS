targetScope = 'managementGroup'
@description('Location for Policy Assignment')
param location string = deployment().location

@description('Management group ID for Policy Assignment')
param ManagementGroupID_PolicyAssignment string = 'AzureITis-landingzones'

@description('Array of virtual network resource IDs to be linked to the private DNS zone')
param virtualNetworkResourceIDs array = [
  '/subscriptions/aa66b139-0ef4-4018-8aa7-b9510bea120a/resourceGroups/rg-hub-flexible-servertests/providers/Microsoft.Network/virtualNetworks/hub-vnet-fleible-servertest'
]

@description('Array of private DNS zone names to be linked to the virtual network')
param privateDNSzoneNames array = [
  '.mysql.database.azure.com'
  '.postgres.database.azure.com'
]

@description('Create Policy Remediation Task')
param createPolicyRemediationTask bool = true

// Azure Role Definition of Private DNS Zone Contributor (b12aa53e-6015-4669-85d0-8515ebb3ae7f)
var roleDefId = 'b12aa53e-6015-4669-85d0-8515ebb3ae7f'

// Deploy Policy Definition
module CreatePrivDNSvnetLink_Definition 'PolicyDefinitions/Definition-CreatePrivDNSvnetLink.bicep' = {
  name: 'Deploy-CreatePrivDNSvnetLink-policyDef-${location}'
}

// Deploy Policy Assignment
module CreatePrivDNSvnetLink_Assignment 'PolicyAssignments/Assignment-CreatePrivDNSvnetLink.bicep' = {
  name: 'Deploy-CreatePrivDNSvnetLink-policyAssign-${location}'
  scope: managementGroup(ManagementGroupID_PolicyAssignment)
  params: {
    location: location
    PolicyDefID: CreatePrivDNSvnetLink_Definition.outputs.PolicyID
    virtualNetworkResourceIDs: virtualNetworkResourceIDs
    privateDNSzoneNames: privateDNSzoneNames
    createPolicyAssignment: createPolicyRemediationTask
  }
}

// Deploy RBAC Assignment. Assign Reader role to the Managed Identity used by the Policy Assignment for remediation
module rbac 'RoleAssignments/rbac-assignment.bicep' = [for (VnetID, i) in virtualNetworkResourceIDs: {
  name: 'Deploy-rbac-${i}-policyAssign-${location}'
  scope: resourceGroup(split(VnetID, '/')[2], split(VnetID, '/')[4])
  params: {
    ManagedIdentityID: CreatePrivDNSvnetLink_Assignment.outputs.ManagedIdentityID
    roleDefinitionId: roleDefId
    VnetName: split(VnetID, '/')[8]
  }
}]

output PolicyDefID string = CreatePrivDNSvnetLink_Definition.outputs.PolicyID
output ManagedIdentityID string = CreatePrivDNSvnetLink_Assignment.outputs.ManagedIdentityID
