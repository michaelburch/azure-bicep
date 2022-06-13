param dnsZoneName string
param recordName string
param recordProperties object
param recordType string = 'CNAME@2018-05-01'

// Public DNS Zone to use
resource targetPublicZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: dnsZoneName
}

resource targetCnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = if (recordType == 'CNAME@2018-05-01') {
  name: recordName
  properties: recordProperties
}

