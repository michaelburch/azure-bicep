param principalId string
param roleGuid string
param delegatedManagedIdentityResourceId string = ''
param targetSubscription string = subscription().id
param principalType string = 'ServicePrincipal'
targetScope = 'resourceGroup'


resource role_assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(targetSubscription, principalId, roleGuid, resourceGroup().id)
  scope: resourceGroup()
  properties: {
    principalType: principalType
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleGuid)
    delegatedManagedIdentityResourceId: !empty(delegatedManagedIdentityResourceId) ? delegatedManagedIdentityResourceId : null
    
  }
}
