targetScope='resourceGroup'

param apimName string
param hostName string
param certificateSecretUri string
param apimCapacity int = 0
param apimSkuName string = 'Consumption'
param location string = resourceGroup().location

resource sourceApim 'Microsoft.ApiManagement/service@2021-12-01-preview' existing = {
  name: apimName
  scope: resourceGroup()
}
var hostnames = concat(sourceApim.properties.hostnameConfigurations, [
  {
    hostName: hostName
    keyVaultId: certificateSecretUri
    type: 'Proxy'
  }
])
var publisherName = sourceApim.properties.publisherName
var publisherEmail = sourceApim.properties.publisherEmail

resource targetApim 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: apimName
  sku: { 
    capacity: apimCapacity
    name: apimSkuName
  }
  location: location
  properties: {
    publisherName: publisherName
    publisherEmail: publisherEmail
    hostnameConfigurations: hostnames
  }
}



