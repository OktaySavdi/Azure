```
AzureActivity
  | where OperationNameValue contains "Microsoft.Authorization/policyExemptions"
  | where ActivityStatus == "Succeeded"
```
