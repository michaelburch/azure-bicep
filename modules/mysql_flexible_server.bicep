@description('Server Name for Azure database for MySQL')
param serverName string

@description('Database administrator login name')
@minLength(1)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@secure()
param administratorLoginPassword string

@description('Azure database for MySQL sku name ')
param skuName string = 'Standard_B1s'

@description('Azure database for MySQL storage Size ')
param StorageSizeGB int = 20

@description('Azure database for MySQL storage Iops')
param StorageIops int = 360

@description('Azure database for MySQL pricing tier')
@allowed([
  'GeneralPurpose'
  'MemoryOptimized'
  'Burstable'
])
param SkuTier string = 'Burstable'

@description('MySQL version')
@allowed([
  '5.7'
  '8.0.21'
])
param mysqlVersion string = '8.0.21'
@description('Location for all resources.')
param location string = resourceGroup().location

@description('MySQL Server backup retention days')
param backupRetentionDays int = 7

@description('Geo-Redundant Backup setting')
param geoRedundantBackup string = 'Disabled'

@description('Subnet Id')
param mysqlSubnetId string

@description('DNS Zone Id')
param zoneId string

@description('Databases to create')
param databases array = []

resource mysqlDbServer 'Microsoft.DBforMySQL/flexibleServers@2021-05-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: SkuTier
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storage: {
      autoGrow: 'Enabled'
      iops: StorageIops
      storageSizeGB: StorageSizeGB
    }
    createMode: 'Default'
    version: mysqlVersion
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    highAvailability: {
      mode: 'Disabled'
    }
    network: {
      delegatedSubnetResourceId: mysqlSubnetId
      privateDnsZoneResourceId: zoneId
    }
  }
}

resource databaseResources 'Microsoft.DBforMySQL/flexibleServers/databases@2021-05-01' = [for db in databases :{
  name: '${db.name}'
  parent: mysqlDbServer
  properties: {
    charset: !empty(db.charset) ? db.charset : 'utf8'
    collation: !empty(db.collation) ? db.collation: 'utf8_general_ci'
  }
}]
