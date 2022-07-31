### Internal nginx-ingress / cert-manager (self-signed) / external-dns

**Create Link DNS Zone**

Go to Azure Portal, open Private DNS zones and a new Private DNS zones.

Make sure your Private DNS zone is linked to AKS VNET.

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#create-a-sp-1)Create a SP
```
az ad sp create-for-rbac -n sp-internal-dns
```
Copy the output with the SP credentials, you will use it later.
### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#get-the-dns-zone-rg-id-1)Get the DNS Zone RG ID

On Azure Portal, go to your DNS Zone Resource Group, click on Properties and copy its ID.

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#get-the-dns-zone-id-1)Get the DNS Zone ID

On Azure Portal, go to your DNS Zone, click on Properties and copy its ID.

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#the-sp-must-be-reader-of-the-dns-zone-rg-1)The SP must be "Reader" of the DNS Zone RG
```
az role assignment create \
  --role "Reader" \
  --assignee "PASTE-YOUR-SP-ID-HERE" \
  --scope "PASTE-YOUR-PRIVATE-DNS-ZONE-RG-ID-HERE"
```
### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#the-sp-must-be-private-dns-zone-contributor-of-the-dns-zone)The SP must be "Private DNS Zone Contributor" of the DNS Zone
```
az role assignment create \
  --role "Private DNS Zone Contributor" \
  --assignee "PASTE-YOUR-SP-ID-HERE" \
  --scope "PASTE-YOUR-PRIVATE-DNS-ZONE-ID-HERE"
```
### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#get-the-tenant-id-1)Get the Tenant ID
```
az account show --query "tenantId"
```
### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#get-the-subscription-id-1)Get the Subscription ID
```
az account show --query "id"
```
### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#get-the-rg-of-the-dns-zone-1)Get the RG of the DNS Zone

On Azure Portal, get the DNs Zone Resource Group name.

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#install-nginx-ingress-1)Install nginx ingress
```
kubectl create namespace ingress-internal
```
```
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
```
```
helm repo update
```
```
helm upgrade -i ingress-internal stable/nginx-ingress \
    --namespace ingress-internal \
    --set controller.publishService.enabled=true \
    --set controller.publishService.pathOverride="ingress-internal/ingress-internal-nginx-ingress-controller" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io\/azure-load-balancer-internal"=true \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
```
### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#install-external-dns-1)Install external-dns

Go to:  [https://github.com/kubernetes-sigs/external-dns/releases](https://github.com/kubernetes-sigs/external-dns/releases)

And get the Docker image tag of the latest release.

Create a namespce.
```
kubectl create ns internal-app
```
Create manifest file.
```
vim external-dns.yaml
```
With the following content.
```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
  namespace: internal-app
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: external-dns
rules:
- apiGroups: [""]
  resources: ["services","endpoints","pods"]
  verbs: ["get","watch","list"]
- apiGroups: ["extensions"] 
  resources: ["ingresses"] 
  verbs: ["get","watch","list"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["list"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
- kind: ServiceAccount
  name: external-dns
  namespace: internal-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
  namespace: internal-app
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: external-dns
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      serviceAccountName: external-dns
      containers:
      - name: external-dns
        image: us.gcr.io/k8s-artifacts-prod/external-dns/external-dns:v0.7.2
        args:
        - --source=service
        - --source=ingress
        - --domain-filter=internal.com
        - --provider=azure-private-dns
        - --azure-resource-group=PASTE-YOUR-PRIVATE-DNS-ZONE-RG-ID-HERE
        - --azure-subscription-id=PASTE-YOUR-SUBSCRIPTION-ID-HERE
        env:
        - name: AZURE_TENANT_ID
          value: "PASTE-YOUR-TENANT-ID-HERE"
        - name: AZURE_CLIENT_ID
          value: "PASTE-YOUR-SP-ID-HERE"
        - name: AZURE_CLIENT_SECRET
          value: "PASTE-YOUR-SP-PASSWORD-HERE"
```
Apply the manifest.
```
kubectl -n internal-app apply -f external-dns.yaml
```
### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#install-cert-manager-1)Install cert-manager

Go to:  [https://cert-manager.io/docs/installation/kubernetes/#steps](https://cert-manager.io/docs/installation/kubernetes/#steps)

And see which is the latest version.

Install cert-manager
```
kubectl create namespace cert-manager
```
```
helm repo add jetstack https://charts.jetstack.io
```
```
helm repo update
```
```
helm upgrade -i cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v0.15.1 \
  --set installCRDs=true
```
List the pods.
```
kubectl get pods -n cert-manager
```
Create a manifest file.
```
vim selfsigned-issuer.yaml
```
With the following content.
```yaml
---
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
```
Apply the manifest.
```
kubectl apply -f selfsigned-issuer.yaml
```
Describe the Cluster Issuer.
```
kubectl describe clusterissuers selfsigned-issuer
```
### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#test-it-1)Test it

Create a manifest file.
```
vim app-internal-app.yaml
```
With the following content.
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: internal-app
spec:
  selector:
    matchLabels:
      app: internal-app
  template:
    metadata:
      labels:
        app: internal-app
    spec:
      containers:
      - image: r.j3ss.co/party-clippy
        name: internal-app
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: internal-app
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: internal-app
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: internal-app
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: "selfsigned-issuer"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  tls:
  - hosts:
    - app.internal.com
    secretName: tls-secret
  rules:
  - host: app.internal.com
    http:
      paths:
      - backend:
          serviceName: internal-app
          servicePort: 80
        path: /(/|$)(.*)
```
Apply the manifest.
```
kubectl -n internal-app apply -f app-internal-app.yaml
```
Get the certificate.
```
kubectl get certificate -n internal-app
```
### [](https://github.com/tadeugr/aks-references/tree/master/AKS-Network#references-6)References

[https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure-private-dns.md](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure-private-dns.md)

[https://cert-manager.io/docs/configuration/selfsigned/](https://cert-manager.io/docs/configuration/selfsigned/)
