param linkedVnetId string
param registrationEnabled bool = false
param name string
param location string = 'Global'

resource symbolicname 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: name
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: linkedVnetId
    }
  }
  location: location
}
