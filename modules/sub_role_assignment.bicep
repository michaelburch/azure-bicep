param principalId string
param roleGuid string
param delegatedManagedIdentityResourceId string = ''
param principalType string = 'ServicePrincipal'
targetScope  = 'subscription'


resource role_assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, principalId, roleGuid)
  scope: subscription()
  properties: {
    principalType: principalType
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleGuid)
    delegatedManagedIdentityResourceId: !empty(delegatedManagedIdentityResourceId) ? delegatedManagedIdentityResourceId : null
    
  }
}
