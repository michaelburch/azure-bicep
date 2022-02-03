param name string
param kubernetesVersion string = '1.22.4'
param defaultNodePoolName string = 'system'
param defaultNodePoolCount int = 1
param defaultNodePoolMinCount int = defaultNodePoolCount
param defaultNodePoolMaxCount int = 3
param defaultNodePoolSize string = 'Standard_B2ms'
param defaultNodePoolMaxPods int = 30
param defaultNodePoolAutoScaling bool = true
param privateCluster bool = true
param uptimeSLA bool = false
param aadGroupIds array = []
param logworkspaceid string
param subnetId string
param dnsPrefix string = name
param privateDnsZoneId string = ''
param identityId string = ''

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: name
  location: resourceGroup().location
  identity: {
    type: empty(identityId) ? 'SystemAssigned' : 'UserAssigned'
    userAssignedIdentities: !empty(identityId) ? { 
      '${identityId}': {}  
    } : null
  }
  sku: {
    name: 'Basic'
    tier:  (uptimeSLA) ? 'Paid' : 'Free'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: dnsPrefix
    //nodeResourceGroup: resourceGroup().name
    agentPoolProfiles: [
      {
        name: defaultNodePoolName
        count: defaultNodePoolCount
        vmSize: defaultNodePoolSize
        mode: 'System'
        maxCount: defaultNodePoolMaxCount
        minCount: defaultNodePoolMinCount
        maxPods: defaultNodePoolMaxPods
        enableAutoScaling: defaultNodePoolAutoScaling
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      outboundType: 'userDefinedRouting'
      dockerBridgeCidr: '172.17.0.1/16'
      dnsServiceIP: '10.0.0.10'
      serviceCidr: '10.0.0.0/16'
      networkPolicy: 'azure'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: privateCluster
      privateDNSZone: !empty(privateDnsZoneId) ? privateDnsZoneId : null
    }
    enableRBAC: true
    aadProfile: {
      adminGroupObjectIDs: aadGroupIds
      enableAzureRBAC: true
      managed: true
      tenantID: subscription().tenantId
    }
    addonProfiles:{
      omsagent: {
        config: {
          logAnalyticsWorkspaceResourceID: logworkspaceid
        }
        enabled: true
      }
      azurepolicy: {
        enabled: true
      }
    }
  }
}


/* module aksPvtNetworkContrib '../Identity/role.bicep' = {
  name: 'aksPvtNetworkContrib'
  params: {
    principalId: principalId
    roleGuid: '4d97b98b-1d4f-4787-a291-c67834d212e7' //Network Contributor
  }
} */
output identityId string = empty(identityId) ? aksCluster.identity.principalId : ''
output location string = aksCluster.location


