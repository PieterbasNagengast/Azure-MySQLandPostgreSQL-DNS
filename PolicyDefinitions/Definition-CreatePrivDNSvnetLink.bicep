targetScope = 'managementGroup'

resource CreatePrivDNSvnetLink 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'CreatePrivDNSvnetLink'
  properties: {
    description: 'Deploy VNET Links to Private DNS Zones. e.g. for MySQL - Flexible Server and PostgreSQL - Flexible Server'
    displayName: 'Deploy VNET Links to Private DNS Zones'
    policyType: 'Custom'
    parameters: {
      virtualNetworkResourceId: {
        type: 'Array'
        metadata: {
          displayName: 'Vnet Resource IDs'
          description: 'Resource ID\'s of VNET\'s to link. The format must be: \'/subscriptions/{subscription id}/resourceGroups/{resourceGroup name}/providers/Microsoft.Network/virtualNetworks/{virtual network name}\''
        }
      }
      privateDNSzoneNames: {
        type: 'array'
        metadata: {
          displayName: 'Private DNS Zone Names'
          description: 'Private DNS Zone Names to link. The format must be: \'.mysql.database.azure.com\''
        }
      }
    }
    mode: 'All'
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Network/privateDnsZones'
            field: 'type'
          }
          {
            count: {
              value: '[parameters(\'privateDNSzoneNames\')]'
              where: {
                field: 'name'
                contains: '[current()]'
              }
            }
            greater: 0
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
                }
                resources: [
                  {
                    type: 'Microsoft.Network/privateDnsZones/virtualNetworkLinks'
                    apiVersion: '2020-06-01'
                    name: '[concat(parameters(\'privateDnsZoneName\'),\'/\',last(split(parameters(\'virtualNetworkResourceId\')[copyIndex()],\'/\')))]'
                    location: 'global'
                    copy: {
                      name: 'vnetlink-counter'
                      count: '[length(parameters(\'virtualNetworkResourceId\'))]'
                    }
                    properties: {
                      registrationEnabled: false
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
