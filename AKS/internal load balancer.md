
## Create an internal load balancer

To create an internal load balancer, create a service manifest named  `internal-lb.yaml`  with the service type  _LoadBalancer_  and the  _azure-load-balancer-internal_  annotation as shown in the following example:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: internal-app
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: internal-app
```

Deploy the internal load balancer using the  [kubectl apply](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply)  and specify the name of your YAML manifest:
```
kubectl apply -f internal-lb.yaml
```

An Azure load balancer is created in the node resource group and connected to the same virtual network as the AKS cluster.

When you view the service details, the IP address of the internal load balancer is shown in the  _EXTERNAL-IP_  column. In this context,  _External_  is in relation to the external interface of the load balancer, not that it receives a public, external IP address. It may take a minute or two for the IP address to change from  _<pending>_  to an actual internal IP address, as shown in the following example:
```
kubectl get service internal-app

NAME           TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
internal-app   LoadBalancer   10.0.248.59   10.240.0.7    80:30555/TCP   2m

```
## [](https://docs.microsoft.com/en-us/azure/aks/internal-lb#specify-an-ip-address)Specify an IP address

If you would like to use a specific IP address with the internal load balancer, add the  _loadBalancerIP_  property to the load balancer YAML manifest. In this scenario, the specified IP address must reside in the same subnet as the AKS cluster but can't already be assigned to a resource. For example, an IP address in the range designated for the Kubernetes subnet within the AKS cluster shouldn't be used.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: internal-app
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
spec:
  type: LoadBalancer
  loadBalancerIP: 10.240.0.25
  ports:
  - port: 80
  selector:
    app: internal-app
```
When deployed and you view the service details, the IP address in the  _EXTERNAL-IP_  column reflects your specified IP address:
```
$ kubectl get service internal-app

NAME           TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
internal-app   LoadBalancer   10.0.184.168   10.240.0.25   80:30225/TCP   4m

```
For more information on configuring your load balancer in a different subnet, see  [Specify a different subnet](https://docs.microsoft.com/en-us/azure/aks/internal-lb#specify-a-different-subnet)

## [](https://docs.microsoft.com/en-us/azure/aks/internal-lb#connect-azure-private-link-service-to-internal-load-balancer-preview)Connect Azure Private Link service to internal load balancer (Preview)

### [](https://docs.microsoft.com/en-us/azure/aks/internal-lb#before-you-begin-1)Before you begin

You must have the following resource installed:

-   The Azure CLI
-   Kubernetes version 1.22.x or above

### [](https://docs.microsoft.com/en-us/azure/aks/internal-lb#create-a-private-link-service-connection)Create a Private Link service connection

To attach an Azure Private Link service to an internal load balancer, create a service manifest named  `internal-lb-pls.yaml`  with the service type  _LoadBalancer_  and the  _azure-load-balancer-internal_  and  _azure-pls-create_  annotation as shown in the example below. For more options, refer to the  [Azure Private Link Service Integration](https://kubernetes-sigs.github.io/cloud-provider-azure/topics/pls-integration/)  design document
```yaml
apiVersion: v1
kind: Service
metadata:
  name: internal-app
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    service.beta.kubernetes.io/azure-pls-create: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: internal-app
```

Deploy the internal load balancer using the  [kubectl apply](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply)  and specify the name of your YAML manifest:
```
kubectl apply -f internal-lb-pls.yaml
```

An Azure load balancer is created in the node resource group and connected to the same virtual network as the AKS cluster.

When you view the service details, the IP address of the internal load balancer is shown in the  _EXTERNAL-IP_  column. In this context,  _External_  is in relation to the external interface of the load balancer, not that it receives a public, external IP address. It may take a minute or two for the IP address to change from  _<pending>_  to an actual internal IP address, as shown in the following example:
```
$ kubectl get service internal-app

NAME           TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
internal-app   LoadBalancer   10.125.17.53  10.125.0.66   80:30430/TCP   64m
```
Additionally, a Private Link Service object will also be created that connects to the Frontend IP configuration of the Load Balancer associated with the Kubernetes service. Details of the Private Link Service object can be retrieved as shown in the following example:
```
$ AKS_MC_RG=$(az aks show -g myResourceGroup --name myAKSCluster --query nodeResourceGroup -o tsv)
$ az network private-link-service list -g ${AKS_MC_RG} --query "[].{Name:name,Alias:alias}" -o table

Name      Alias
--------  -------------------------------------------------------------------------
pls-xyz   pls-xyz.abc123-defg-4hij-56kl-789mnop.eastus2.azure.privatelinkservice


```
## [](https://docs.microsoft.com/en-us/azure/aks/internal-lb#specify-a-different-subnet)Specify a different subnet

To specify a subnet for your load balancer, add the  _azure-load-balancer-internal-subnet_  annotation to your service. The subnet specified must be in the same virtual network as your AKS cluster. When deployed, the load balancer  _EXTERNAL-IP_  address is part of the specified subnet.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: internal-app
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    service.beta.kubernetes.io/azure-load-balancer-internal-subnet: "apps-subnet"
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: internal-app
```
