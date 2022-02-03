// Lighthouse delegation for use in a hub & spoke architecture
// Delegates BuiltIn Roles in the hub to a service principal in another tenant (spoke). 
// A module is used to scope the assignment to a specific resource group 
// Can be used to allows spokes in one tenant to update networking resources in single resource group another tenant (hub)  
targetScope = 'subscription'
// List of Azure roles with friendly names and guids
// Created with az role definition list --output json --query "[? roleType=='BuiltInRole'].{id:name,roleName:roleName}"  | jq -r 'map ({(.roleName): .id})|add' > azure-roles.json
var azureRoles = json(loadTextContent('./azure-roles.json'))
@description('Specify a unique name for your offer')
param mspOfferName string = 'Deployment Roles Delegation'

@description('Name of the Managed Service Provider offering')
param mspOfferDescription string = 'Delegation of roles to service principal in remote tenant'

@description('Specify the tenant id of the Managed Service Provider')
param managedByTenantId string 

@description('Specify the id of a principal in the managedByTenant')
param managedByPrincipalId string 

@description('Specify an array of objects, containing tuples of Azure Active Directory principalId, a Azure roleDefinitionId, and an optional principalIdDisplayName. The roleDefinition specified is granted to the principalId in the provider\'s Active Directory and the principalIdDisplayName is visible to customers.')
var authorizations = [
  // See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for role definition ids
  {
    // Network Contributor
    principalId: managedByPrincipalId
    roleDefinitionId: azureRoles['Network Contributor']
    principalIdDisplayName: 'devops-spn'
  }
  {
    // Private DNS Zone Contributor
    principalId: managedByPrincipalId
    roleDefinitionId: azureRoles['Private DNS Zone Contributor']
    principalIdDisplayName: 'devops-spn'
  }
  {
    // DNS Zone Contributor
    principalId: managedByPrincipalId
    roleDefinitionId: azureRoles['DNS Zone Contributor']
    principalIdDisplayName: 'devops-spn'
  }
  {
    // ACR Pull
    principalId: managedByPrincipalId
    roleDefinitionId: azureRoles.AcrPull
    principalIdDisplayName: 'devops-spn'
  }
  {
    // ACR Push
    principalId: managedByPrincipalId
    roleDefinitionId: azureRoles.AcrPush
    principalIdDisplayName: 'devops-spn'
  }
]
param rgName string = 'resourceGroup'

resource mspRegistration 'Microsoft.ManagedServices/registrationDefinitions@2020-02-01-preview' = {
  name: guid(mspOfferName)
  properties: {
    registrationDefinitionName: mspOfferName
    description: mspOfferDescription
    managedByTenantId: managedByTenantId
    authorizations: authorizations
  }
}
// Limit delegation to single resource group 
module registrationAssignment './modules/registration_assignment.bicep' = {
  name: guid(mspOfferName)
  scope: resourceGroup(rgName)
  params: {
    registrationName: guid(mspOfferName)
    registrationDefinitionId: mspRegistration.id
  }
}


output mspOfferName string = 'Managed by ${mspOfferName}'
output authorizations array = authorizations
