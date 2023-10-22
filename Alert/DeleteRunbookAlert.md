AzureActivity 
| where OperationNameValue == "MICROSOFT.AUTOMATION/AUTOMATIONACCOUNTS/RUNBOOKS/DELETE"
| where ActivityStatusValue == "Success"
