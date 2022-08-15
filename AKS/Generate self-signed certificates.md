
# Generate self-signed certificates

Generate a Private Key.
```
openssl genrsa -out bob.key 4096
```
Generate a Certificate Signing Request (CSR).
```
openssl req -new -key bob.key -out bob.csr -subj "/CN=bob/O=engineers"
```
Base64 encode the CSR.
```
cat bob.csr | base64 | tr -d '\n'
```
Create a  `CertificateSigningRequest`  manifest file.
```
vi signing-request.yaml
```
With the following content.
```yaml
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: bob-csr
spec:
  groups:
  - system:authenticated
 
  request: PASTE-THE-CSR-BASE64-HERE
  
  usages:
  - digital signature
  - key encipherment
  - client auth
```
Create the CSR on Kubernentes.
```
kubectl create -f signing-request.yaml
```
Approve the CSR.
```
kubectl certificate approve bob-csr
```
Get the Signed Certificate (CRT).
```
kubectl get csr bob-csr -o jsonpath='{.status.certificate}' | base64 --decode > bob.crt
```
# [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#create-kubeconfig-files-for-users)Create kubeconfig files for users

## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#examples-1)Examples

Create a kubeconfig file for a user using self-signed certificates, editing an orignal kubeconfig file.

Get an original kubeconfig file.

```
az aks get-credentials \
  --name YOUR-AKS-NAME
  --resource-group YOUR-AKS-RG \
  --file ./template.kubeconfig
  --admin
```
Get the The CRT base64 encoded.
```
cat bob.crt | base64 | tr -d '\n'
```
Get the The Key base64 encoded.
```
cat bob.key | base64 | tr -d '\n'
```
Edit the kubeconfig file.
```
vi ./template.kubeconfig
```

Keep the  `.clusters.cluster.certificate-authority-data`  of the original file.

Keep the  `.clusters.cluster.server`  of the original file.

Change  `.contexts.context.user`  and  `.users.name`. They have to match.

Paste the "CRT BASE64" in the  `.users.user.client-certificate-data`.

Paste the "KEY BASE64" in the  `.users.user.client-key-data`.

The kubeconfig file bellow is just na example.

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JS...
    server: https://aks-lb-sta-aks-network-fbca3e-563769af.hcp.brazilsouth.azmk8s.io:443
  name: aks-lb-standard
contexts:
- context:
    cluster: aks-lb-standard
    user: bob_aks-network_aks-lb-standard
  name: aks-lb-standard-admin
current-context: aks-lb-standard-admin
kind: Config
preferences: {}
users:
- name: bob_aks-network_aks-lb-standard
  user:
    client-certificate-data: PASTE THE "CRT BASE64" HERE
    client-key-data: PASTE THE "KEY BASE64" HERE
```
# [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#rbac-for-kubernetes-users-and-groups)RBAC for Kubernetes Users and Groups

## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#examples-2)Examples

## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#rbac-for-users)RBAC for Users

`.subjects.apiGroup.name`  has to match certificate's Common Name (`CN`).
```
openssl req -new -key bob.key -out bob.csr -subj "/CN=bob/O=engineers"
```
```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: crb-admin-usr-bob
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: bob
```
## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#rbac-for-groups)RBAC for Groups

`.subjects.apiGroup.name`  has to match certificate's organization (`O`).
```
openssl req -new -key bob.key -out bob.csr -subj "/CN=bob/O=engineers"
```
```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: crb-admin-usr-bob
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: engineers
```
# [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#-hands-on--kubernetes-users)[ HANDS-ON ] Kubernetes users

## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#generate-the-private-key)Generate the Private Key

```
openssl genrsa -out bob.key 4096
```
## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#generate-the-csr)Generate the CSR
```
openssl req -new -key bob.key -out bob.csr -subj "/CN=bob/O=engineers"
```
## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#get-the-csr-base64-encoded)Get the CSR base64 encoded
```
cat bob.csr | base64 | tr -d '\n'
```
## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#k8s-csr-manifest)K8s CSR manifest

Create a new file.
```
vim signing-request.yaml
```
With the following content.
```yaml
---
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
 name: bob-csr
spec:
 groups:
 - system:authenticated
 request: PASTE-THE-CSR-BASE64-HERE

 usages:
 - digital signature
 - key encipherment
 - client auth
```
Apply the manifest.
```
kubectl apply -f signing-request.yaml
```
Get the CSR.
```
kubectl get csr
```
## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#approve-the-csr)Approve the CSR

```
kubectl certificate approve bob-csr
```
Get the CSR again.
```
kubectl get csr
```
## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#get-the-signed-certificate)Get the signed certificate

```
kubectl get csr bob-csr -o jsonpath='{.status.certificate}' | base64 --decode > bob.crt
```
Cat the file.
```
cat bob.crt
```

## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#get-an-existing-kubeconfig)Get an existing kubeconfig

```
AKS_NAME="PASTE-YOUR-CLUSTER-NAME-HERE"
AKS_RG="PASTE-YOUR-CLUSTER-RG-HERE"
AKS_REGION="PASTE-YOUR-CLUSTER-REGION-HERE"
AKS_SUBSCRIPTION="PASTE-YOUR-CLUSTER-SUBSCRIPTION-HERE"
```
```
az aks get-credentials \
  -n $AKS_NAME \
  -g $AKS_RG \
  --subscription $AKS_SUBSCRIPTION \
  --admin \
  --file ./template.kubeconfig
```

## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#get-the-crt-base64-encoded)Get the CRT base64 encoded

```
cat bob.crt | base64 | tr -d '\n'
```

## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#get-the-key-base64-encoded)Get the key base64 encoded

```
cat bob.key | base64 | tr -d '\n'
```

## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#edit-the-kubeconfig-file)Edit the kubeconfig file

```
vi ./template.kubeconfig
```
Replace the "user".

`client-certificate-data`  = CRT

`client-key-data`  = KEY

## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#test-the-new-kubeconfig-file)Test the new kubeconfig file

```
mv template.kubeconfig bob.kubeconfig
export KUBECONFIG=./bob.kubeconfig
kubectl get nodes
```

## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#rbac-for-the-user)RBAC for the user

Using your admin kubeconfig...

Create a new file.
```
vim rbac-user.yaml
```
With the following content.
```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: crb-admin-usr-bob
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: bob

```
Apply the manifest.
```
kubectl apply -f rbac-user.yaml
```
## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#test-permissions)Test permissions

Using Bob's kubeconfig...
```
kubectl get nodes
```
## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#revoke-permissions)Revoke permissions

Using your admin kubeconfig...

Delete the RBAC

```
kubectl delete -f rbac-user.yaml
```
## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#rbac-for-the-group)RBAC for the group

Using your admin kubeconfig...

Create a new file.
```
vim rbac-group.yaml
```
With the following content.
```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: crb-admin-usr-bob
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: engineers
```
Apply the manifest.
```
kubectl apply -f rbac-group.yaml
```
## [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#test-permissions-1)Test permissions

Using Bob's kubeconfig...
```
kubectl get nodes
```
## References

### [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#request-signing-process)Request signing process

[https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#request-signing-process](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#request-signing-process)

### [](https://github.com/tadeugr/aks-references/tree/master/Kubernetes-users#a-practical-approach-to-understanding-kubernetes-authentication)A Practical Approach to Understanding Kubernetes Authentication

[https://thenewstack.io/a-practical-approach-to-understanding-kubernetes-authentication/](https://thenewstack.io/a-practical-approach-to-understanding-kubernetes-authentication/)

### aks-references
https://github.com/tadeugr/aks-references
