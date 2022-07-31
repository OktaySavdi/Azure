**Buy a domain**

Go to Azure Portal, App Service Domains and buy a new domain. Azure will create the domain and a DNS Zone for the domain.

**Create a SP**
```
az ad sp create-for-rbac -n sp-external-dns
```
Copy the output with the SP credentials, you will use it later.

**Get the DNS Zone RG ID**

On Azure Portal, go to your DNS Zone Resource Group, click on Properties and copy its ID.

**Get the DNS Zone ID**

On Azure Portal, go to your DNS Zone, click on Properties and copy its ID.

The SP must be "Reader" of the DNS Zone RG
```
az role assignment create \
  --role "Reader" \
  --assignee "PASTE-YOUR-SP-ID-HERE" \
  --scope "PASTE-YOUR-DNS-ZONE-RG-ID-HERE"
```
The SP must be "Contributor" of the DNS Zone
```
az role assignment create \
  --role "Contributor" \
  --assignee "PASTE-YOUR-SP-ID-HERE" \
  --scope "PASTE-YOUR-DNS-ZONE-ID-HERE"
```
**Get the Tenant ID**
```
az account show --query "tenantId"
```
Get the Subscription ID
```
az account show --query "id"
```
**Get the RG of the DNS Zone**

On Azure Portal, get the DNS Zone Resource Group name.

Create credentials file
```
vim azure.json
```
Paste the following content.
```json
{
  "tenantId": "PASTE-YOUR-TENANT-ID-HERE",
  "subscriptionId": "PASTE-YOUR-SUBSCRIPTION-ID-HERE",
  "resourceGroup": "PASTE-YOUR-DNS-ZONE-RG-NAME-HERE",
  "aadClientId": "PASTE-YOUR-SP-ID-HERE",
  "aadClientSecret": "PASTE-YOUR-SP-SECRET-HERE"
}
```
Create a Kubernetes secret
```
kubectl create ns my-app
```
```
kubectl create secret generic azure-config-file --from-file=./azure.json -n my-project
```
Install nginx ingress
```
kubectl create namespace ingress-external
```
```
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
```
```
helm repo update
```
```bash
helm upgrade -i ingress-external stable/nginx-ingress \
    --namespace ingress-external \
    --set controller.publishService.enabled=true \
    --set controller.publishService.pathOverride="ingress-external/ingress-external-nginx-ingress-controller" \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
Install external-dns
Go to: https://github.com/kubernetes-sigs/external-dns/releases
```
And get the Docker image tag of the latest release.

Create a manifest file.
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
  namespace: my-app
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
  namespace: my-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
  namespace: my-app
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
        - --domain-filter=my-domain.com
        - --provider=azure
        - --azure-resource-group=REPLACE-WITH-YOUR-DNS-ZONE-RG
        volumeMounts:
        - name: azure-config-file
          mountPath: /etc/kubernetes
          readOnly: true
      volumes:
      - name: azure-config-file
        secret:
          secretName: azure-config-file
```
Apply the manifest.
```
kubectl -n my-app apply -f external-dns.yaml
```
**Install cert-manager**

Go to: https://cert-manager.io/docs/installation/kubernetes/#steps

And see which is the latest version.

Install cert-manager.
```
kubectl create namespace cert-manager
```
```
helm repo add jetstack https://charts.jetstack.io
```
```
helm repo update
```
```bash
helm upgrade -i cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v0.15.1 \
  --set installCRDs=true
```
Get the pods.
```
kubectl get pods -n cert-manager
```
Create a manifest.
```
vim letsencrypt.yaml
```
With the following content.
```yaml
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: tadeugraz@outlook.com
    privateKeySecretRef:
      name: letsencrypt
    solvers:
    - http01:
        ingress:
          class: nginx
```
Apply the manifest
```
kubectl apply -f letsencrypt.yaml
```
Describe the cluster issuer.
```
kubectl describe clusterissuers letsencrypt
```
**Test it**

Create a manifest.
```
vim app-my-app.yaml
```
With the following content.
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - image: r.j3ss.co/party-clippy
        name: my-app
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: my-app
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: my-app
  type: ClusterIP

---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: my-app
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: "letsencrypt"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  tls:
  - hosts:
    - app.my-domain.com
    secretName: tls-secret
  rules:
  - host: app.my-domain.com
    http:
      paths:
      - backend:
          serviceName: my-app
          servicePort: 80
        path: /(/|$)(.*)
```
Apply the manifest.
```
kubectl -n my-app apply -f app-my-app.yaml
```
Get the certificate.
```
kubectl get certificate -n my-app
```
References
https://docs.microsoft.com/en-us/azure/aks/ingress-tls

https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md

https://github.com/helm/charts/tree/master/stable/nginx-ingress

https://cert-manager.io/docs/installation/kubernetes/
