// Lighthouse delegation for use in a hub & spoke architecture
// Delegates BuiltIn Roles in the spoke to a service principal in another tenant (hub)
// Assignment is done at the subscription level  
targetScope = 'subscription'
// List of Azure roles with friendly names and guids
// Created with az role definition list --output json --query "[? roleType=='BuiltInRole'].{id:name,roleName:roleName}"  | jq -r 'map ({(.roleName): .id})|add' > azure-roles.json
var azureRoles = json(loadTextContent('./azure-roles.json'))
@description('Specify a unique name for your offer')
param mspOfferName string = 'Hub Deployment Delegation'

@description('Name of the Managed Service Provider offering')
param mspOfferDescription string = 'Delegation of roles to service principal in hub tenant'

@description('Specify the tenant id of the Managed Service Provider')
param managedByTenantId string 

@description('Specify the id of a principal in the managedByTenant')
param managedByPrincipalId string 
// Retrieve with az ad sp list --display-name <sp display name> --query '[].objectId'

@description('Specify an array of objects, containing tuples of Azure Active Directory principalId, a Azure roleDefinitionId, and an optional principalIdDisplayName. The roleDefinition specified is granted to the principalId in the provider\'s Active Directory and the principalIdDisplayName is visible to customers.')
var authorizations = [
  // See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for role definition ids
  {
    // Contributor
    principalId: managedByPrincipalId
    roleDefinitionId: azureRoles.Contributor
    principalIdDisplayName: 'mb-vse-devops-spn'
  }
  {
    // User Access Administrator
    principalId: managedByPrincipalId
    roleDefinitionId: azureRoles['User Access Administrator']
    principalIdDisplayName: 'mb-vse-devops-spn'
    delegatedRoleDefinitionIds: [
      azureRoles.Contributor // Contributor
      azureRoles['Network Contributor'] // Network Contributor
      azureRoles['Private DNS Zone Contributor'] // Private DNS Zone Contributor
      azureRoles['DNS Zone Contributor'] // DNS Zone Contributor
    ]
  }
]

resource mspRegistration 'Microsoft.ManagedServices/registrationDefinitions@2020-02-01-preview' = {
  name: guid(mspOfferName)
  properties: {
    registrationDefinitionName: mspOfferName
    description: mspOfferDescription
    managedByTenantId: managedByTenantId
    authorizations: authorizations
  }
}

resource registrationAssignment 'Microsoft.ManagedServices/registrationAssignments@2020-02-01-preview' = {
  name: guid(mspRegistration.name)
  properties: {
    registrationDefinitionId: mspRegistration.id
  }
}

output mspOfferName string = 'Managed by ${mspOfferName}'
output authorizations array = authorizations
