targetScope = 'managementGroup'
param location string = deployment().location
@description('Management group ID for Policy Assignment')
param ManagementGroupID_PolicyAssignment string = 'AzureITis'
param virtualNetworkResourceIDs array = [
  '/subscriptions/5a287c9e-8d7f-4a12-b74b-41d992cb3f56/resourceGroups/rg-jira-routed-vnet/providers/Microsoft.Network/virtualNetworks/RoutedVNET'
]

var roleDefId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

module CreatePrivDNSvnetLink_Definition 'modules/Definition-CreatePrivDNSvnetLink.bicep' = {
  name: 'Deploy-CreatePrivDNSvnetLink-policyDef-${location}'
}

module CreatePrivDNSvnetLink_Assignment 'modules/Assignment-CreatePrivDNSvnetLink.bicep' = {
  name: 'Deploy-CreatePrivDNSvnetLink-policyAssign-${location}'
  scope: managementGroup(ManagementGroupID_PolicyAssignment)
  params: {
    location: location
    PolicyDefID: CreatePrivDNSvnetLink_Definition.outputs.PolicyID
    virtualNetworkResourceIDs: virtualNetworkResourceIDs
  }
}

module rbac 'modules/rbac-assignment.bicep' = [for (VnetID,i) in virtualNetworkResourceIDs: {
  name: 'Deploy-rbac-${i}-policyAssign-${location}'
  scope: resourceGroup(split(VnetID,'/')[2],split(VnetID,'/')[4])
  params: {
    ManagedIdentityID: CreatePrivDNSvnetLink_Assignment.outputs.ManagedIdentityID
    roleDefinitionId: roleDefId
    VnetName: split(VnetID,'/')[8]
  }
}]

output PolicyDefID string = CreatePrivDNSvnetLink_Definition.outputs.PolicyID
output ManagedIdentityID string = CreatePrivDNSvnetLink_Assignment.outputs.ManagedIdentityID
