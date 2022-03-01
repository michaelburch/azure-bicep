param nsgName string
param location string = resourceGroup().location
param secRules array = []
param tags object = {}
targetScope = 'resourceGroup'

resource nsg  'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: secRules
  }
  tags: tags
}

output id string = nsg.id
