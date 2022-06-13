targetScope='resourceGroup'

param hostName string
param certificateSecretUri string
param sourceApim object
param sourceApimName string

var hostnames = concat(sourceApim.properties.hostnameConfigurations, [
  {
    hostName: hostName
    keyVaultId: certificateSecretUri
    type: 'Proxy'
  }
])

resource targetApim 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: sourceApimName
  sku: sourceApim.sku
  location: sourceApim.location
  properties: {
    publisherName: sourceApim.properties.publisherName
    publisherEmail: sourceApim.properties.publisherEmail
    hostnameConfigurations: hostnames
  }
}



