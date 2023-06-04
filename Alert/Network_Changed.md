```
AzureActivity
| where OperationNameValue == "MICROSOFT.NETWORK/VIRTUALNETWORKS/WRITE"
| where ActivityStatusValue == "Success"
| extend CentralTime = datetime_utc_to_local(TimeGenerated, 'Europe/Vienna')
| extend EntityProperty = parse_json(tostring(Properties_d)).entity
| extend Resource = parse_json(tostring(Properties_d)).resource
| where isnotnull(EntityProperty) or isnotnull(Resource)
| project
    CentralTime,
    SubscriptionId,
    ResourceGroup,
    Level,
    ActivityStatusValue,
    Caller,
    Resource,
    EntityProperty,
    OperationNameValue
```
