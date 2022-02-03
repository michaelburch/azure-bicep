param registrationDefinitionId string
param registrationName string

resource registrationAssignment 'Microsoft.ManagedServices/registrationAssignments@2020-02-01-preview' = {
  name: guid(registrationName)
  properties: {
    registrationDefinitionId: registrationDefinitionId
  }
}
