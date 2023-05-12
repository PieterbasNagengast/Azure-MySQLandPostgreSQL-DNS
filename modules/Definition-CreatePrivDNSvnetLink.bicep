targetScope = 'managementGroup'

var policyName = 'CreatePrivDNSvnetLink'
var policyDescription = 'CreatePrivDNSvnetLink'
var policyDisplayName = 'CreatePrivDNSvnetLink'

resource CreatePrivDNSvnetLink 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    description: policyDescription
    displayName: policyDisplayName
    policyType: 'Custom'
    parameters: {
      virtualNetworkResourceId: {
        type: 'Array'
        metadata: {
          displayName: 'Vnet Resource IDs'
          description: 'Resource Ids of a vNet to link. The format must be: \'/subscriptions/{subscription id}/resourceGroups/{resourceGroup name}/providers/Microsoft.Network/virtualNetworks/{virtual network name}\''
        }
      }
      registrationEnabled: {
        type: 'Boolean'
        metadata: {
          displayName: 'Enable Registration'
          description: 'Enables automatic DNS registration in the zone for the linked vNet.'
        }
        defaultValue: false
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Network/privateDnsZones'
            field: 'type'
          }
          {
            field: 'name'
            contains: '.mysql.database.azure.com'
          }
        ]
      }
      then: {
        details: {
          existenceCondition: {
            allOf: [
              {
                equals: 'Microsoft.Network/privateDnsZones/virtualNetworkLinks'
                field: 'type'
              }
              {
                in: '[parameters(\'virtualNetworkResourceId\')]'
                field: 'Microsoft.Network/privateDnsZones/virtualNetworkLinks/virtualNetwork.id'
              }
              {
                field: 'name'
                contains: '.mysql.database.azure.com'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                privateDnsZoneName: {
                  value: '[field(\'name\')]'
                }
                virtualNetworkResourceId: {
                  value: '[parameters(\'virtualNetworkResourceId\')]'
                }
                registrationEnabled: {
                  value: '[parameters(\'registrationEnabled\')]'
                }
              }
              template: {
                '$schema': 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  privateDnsZoneName: {
                    type: 'string'
                  }
                  virtualNetworkResourceId: {
                    type: 'array'
                  }
                  registrationEnabled: {
                    type: 'bool'
                  }
                }
                resources: [
                  {
                    type: 'Microsoft.Network/privateDnsZones/virtualNetworkLinks'
                    apiVersion: 2018-09-01
                    name: '[concat(parameters(\'privateDnsZoneName\')\'/\'concat(parameters(\'privateDnsZoneName\')\'-\' last(split(parameters(\'virtualNetworkResourceId\')[copyIndex()]\'/\'))))]'
                    location: 'global'
                    copy: {
                      name: 'vnetlink-counter'
                      count: '[length(parameters(\'virtualNetworkResourceId\'))]'
                    }
                    properties: {
                      registrationEnabled: '[parameters(\'registrationEnabled\')]'
                      virtualNetwork: {
                        id: '[parameters(\'virtualNetworkResourceId\')[copyIndex()]]'
                      }
                    }
                  }
                ]
              }
            }
          }
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/b12aa53e-6015-4669-85d0-8515ebb3ae7f'
          ]
          type: 'Microsoft.Network/privateDnsZones/virtualNetworkLinks'
        }
        effect: 'deployIfNotExists'
      }
    }
  }
}

output PolicyID string = CreatePrivDNSvnetLink.id