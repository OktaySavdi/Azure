AzureActivity 
| where OperationNameValue == "MICROSOFT.AUTHORIZATION/POLICYASSIGNMENTS/DELETE"
| where ActivityStatusValue == "Success"
