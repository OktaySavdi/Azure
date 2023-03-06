
#First console
```
CLUSTER_RESOURCE_GROUP=$(az aks show --resource-group azweu-rg-hce-test-01 --name os1 --query nodeResourceGroup -o tsv)
```  
```
SCALE_SEt_NAME=$(az vmss list --resource-group $CLUSTER_RESOURCE_GROUP --query [0].name -o tsv)
```
#First console
```
az vmss extension set \
--resource-group $CLUSTER_RESOURCE_GROUP \
--vmss-name $SCALE_SET_NAME \
--name VMAccessForLinux \
--publisher Microsoft.OSTCExtensions \
--version=1.4 \
--protected-settings "{\"username\":\"azureuser\", \"ssh_key\":\"$(cat ~/.ssh/id_rsa.pub)\"}"
```
#First console
```
az vmss update-instances --instance-ids '*' \
--resource-group $CLUSTER_RESOURCE_GROUP \
--name $SCALE_SET_NAME
``` 
#First console
```
kubectl run -it --rm aks-ssh --image=debian
```
```
apt-get update && apt-get install openssh-client -y
```
#Second console
```
kubectl cp ~/.ssh/id_rsa $(kubectl get po -l run=aks-ssh -o jsonpath='{.items[0].metadata.name}'):/id_rsa
```
```
kubectl get nodes -o wide
```
#First console
```
chmod 0600 id_rsa
```
``` 
ssh -i id_rsa azureuser@10.224.0.4
```
