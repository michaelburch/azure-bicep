targetScope='resourceGroup'

param apimName string
param hostName string
param certificateId string

resource targetApim 'Microsoft.ApiManagement/service@2021-12-01-preview' existing = {
  name: apimName
  scope: resourceGroup()
}

resource newGateway 'Microsoft.ApiManagement/service/gateways@2021-12-01-preview' = {
  name: uniqueString(hostName,'-gw')
  parent: targetApim
}

resource hostnameConfig 'Microsoft.ApiManagement/service/gateways/hostnameConfigurations@2021-12-01-preview' = {
  name: uniqueString(hostName,'-config')
  parent: newGateway
  properties: {
    hostname: hostName
    certificateId: certificateId
  }
}


