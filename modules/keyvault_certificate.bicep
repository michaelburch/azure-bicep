targetScope='resourceGroup'

param resourceGroupName string
param vaultName string
param certificateName string
resource targetVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: vaultName
  scope: resourceGroup(resourceGroupName)
}
resource requestedCert 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' existing = {
  name: certificateName
  parent: targetVault
}

output secretUri string = requestedCert.properties.secretUri
output contentType string = requestedCert.properties.contentType
output secretUriWithVersion string = requestedCert.properties.secretUriWithVersion
output attributes object = requestedCert.properties.attributes
