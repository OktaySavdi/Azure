```
AzureActivity
//| where TimeGenerated > ago(13days)
| where OperationNameValue contains "MICROSOFT.NETWORK/VIRTUALNETWORKS/"
    and OperationNameValue != "MICROSOFT.NETWORK/VIRTUALNETWORKS/TAGGEDTRAFFICCONSUMERS/VALIDATE/ACTION"
    and OperationNameValue != "MICROSOFT.NETWORK/VIRTUALNETWORKS/TAGGEDTRAFFICCONSUMERS/WRITE"
    and OperationNameValue != "MICROSOFT.NETWORK/VIRTUALNETWORKS/SUBNETS/SERVICEASSOCIATIONLINKS/VALIDATE/ACTION"
    and OperationNameValue != "MICROSOFT.NETWORK/VIRTUALNETWORKS/SUBNETS/SERVICEASSOCIATIONLINKS/WRITE"
    and OperationNameValue != "MICROSOFT.NETWORK/VIRTUALNETWORKS/SUBNETS/SERVICEASSOCIATIONLINKS/DELETE"
    and OperationNameValue != "MICROSOFT.NETWORK/VIRTUALNETWORKS/REMOTEVIRTUALNETWORKPEERINGPROXIES/WRITE"
    and OperationNameValue != "MICROSOFT.NETWORK/VIRTUALNETWORKS/VIRTUALNETWORKPEERINGS/WRITE"
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
