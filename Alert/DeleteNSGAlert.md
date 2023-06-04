```
AzureActivity 
| where OperationNameValue == "MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/DELETE"
| where ActivityStatusValue == "Success"
```
