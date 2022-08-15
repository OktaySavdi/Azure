# Provisioners


### Dynamic Volumes

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#create-a-dynamic-volume-using-azure-disk-sc)Create a dynamic volume using azure-disk SC

Create a PVC and azure will provision a disk and create the PV.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-managed-disk
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: managed-premium
  resources:
    requests:
      storage: 5Gi

```

Mount the volume in a Pod.

```
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx
    volumeMounts:
    - mountPath: "/mnt/azure"
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: azure-managed-disk

```

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#create-a-dynamic-volume-using-azure-file-sc)Create a dynamic volume using azure-file SC

Create a PVC and azure will provision a Storage Class and create the PV.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurefile
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile
  resources:
    requests:
      storage: 5Gi

```

Mount the volume in a Pod.

```
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx
    volumeMounts:
    - mountPath: "/mnt/azure"
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: azurefile

```

# Static Volumes

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#use-a-static-disk-azure-disk)Use a static Disk (azure-disk)

Get the disk URI.

```
az disk show \
  --name MY-DISK-NAME \
  --resource-group MY-DISK-RESOURCE-GROUP \
  --subscription MY-DISK-SUBSCRIPTION

```

Output example.

```
...
"id": "/subscriptions/7a87b86a-eecb-4e2a-8a94-2360e443dba3/resourceGroups/MY-DISK-RESOURCE-GROUP/providers/Microsoft.Compute/disks/MY-DISK-NAME",
...

```

Mount the volume in a Pod.

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - image: nginx:1.15.5
    name: mypod
    volumeMounts:
      - name: azure
        mountPath: /mnt/azure
  volumes:
      - name: azure
        azureDisk:
          kind: Managed
          diskName: REPLACE-WITH-YOUR-DISK-NAME
          diskURI: REPLACE-WITH-YOUR-DISK-URI

```

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#use-a-static-storage-account-azure-file)Use a static Storage Account (azure-file)

Go to Azure Portal and get your Storage Account Name and Key.

Export these env vars.

```
STORAGE_ACCOUNT_NAME="sa20c11e0a"
STORAGE_KEY="Z2WjB+uBVksEiA+3A8pq19MYQfTcIZQzXaRowrW9Twe+1AW+MppRIxFw=="

```

Create a Kubernetes secret.

```
kubectl create secret generic azure-secret \
  --from-literal=azurestorageaccountname=$STORAGE_ACCOUNT_NAME \
  --from-literal=azurestorageaccountkey=$STORAGE_KEY

```

#### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#mount-a-static-storage-account-directly-in-the-pod)Mount a static Storage Account directly in the Pod

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - image: nginx:1.15.5
    name: mypod
    volumeMounts:
      - name: azure
        mountPath: /mnt/azure
  volumes:
  - name: azure
    azureFile:
      secretName: azure-secret
      shareName: REPLACE-WITH-YOUR-SHARE-NAME
      readOnly: false

```

#### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#mount-a-static-storage-account-using-a-pv-and-a-pvc)Mount a static Storage Account using a PV and a PVC

Create a PV.

Notice the  `my-static-file-link`. It is not a proper  `StorageClass`, it is only a reference to be used in the PVC.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-static-file-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  storageClassName: my-static-file-link
  azureFile:
    secretName: azure-secret
    shareName: REPLACE-WITH-YOUR-SHARE-NAME
    readOnly: false
  mountOptions:
  - dir_mode=0777
  - file_mode=0777
  - uid=1000
  - gid=1000
  - mfsymlinks
  - nobrl

```

Create a PVC.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-static-file-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: my-static-file-link
  resources:
    requests:
      storage: 5Gi

```

Mount it in a Pod.

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - image: nginx:1.15.5
    name: mypod
    volumeMounts:
      - name: azure
        mountPath: /mnt/azure
  volumes:
  - name: azure
    persistentVolumeClaim:
      claimName: my-static-file-pvc

```

# [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#-hands-on--dynamic-volumes)[ HANDS-ON ] Dynamic Volumes

## [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#azure-disk)Azure Disk

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#create-the-pvc)Create the PVC

Create a manifest file.

```
vim pvc-azure-managed-disk.yaml

```

With the following content.

```
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-managed-disk
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: managed-premium
  resources:
    requests:
      storage: 5Gi

```

Apply the manifest.

```
kubectl apply -f pvc-azure-managed-disk.yaml

```

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#mount-it-in-a-pod)Mount it in a Pod

Create a manifest file.

```
vim pod-disk.yaml

```

With the following content.

```
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod-disk
spec:
  containers:
  - name: mypod
    image: nginx
    volumeMounts:
    - mountPath: "/mnt/azure"
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: azure-managed-disk

```

Apply the manifest.

```
kubectl apply -f pod-disk.yaml

```

## [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#azure-file)Azure File

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#create-the-pvc-1)Create the PVC

Create a manifest file.

```
vim pvc-azurefile.yaml

```

With the following content.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurefile
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile
  resources:
    requests:
      storage: 5Gi

```

Apply the manifest.

```
kubectl apply -f pvc-azurefile.yaml

```

Describe the secret.

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#mount-it-in-a-pod-1)Mount it in a Pod

Create a manifest file.

```
vim pod-file.yaml

```

With the following content.

```
kind: Pod
apiVersion: v1
metadata:
  name: mypod-file
spec:
  containers:
  - name: mypod
    image: nginx
    volumeMounts:
    - mountPath: "/mnt/azure"
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: azurefile

```

Apply the manifest.

```
kubectl apply -f pod-file.yaml

```

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#create-another-pvc-same-sku)Create another PVC (same SKU)

Create a manifest file.

```
vim pvc-azurefile-002.yaml

```

With the following content.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurefile-002
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile
  resources:
    requests:
      storage: 10Gi

```

Apply the manifest.

```
kubectl apply -f pvc-azurefile-002.yaml

```

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#create-another-pvc-different-sku)Create another PVC (different SKU)

Create a manifest file.

```
vim pvc-azurefile-003.yaml

```

With the following content.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurefile-003
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile-premium
  resources:
    requests:
      storage: 100Gi

```

Apply the manifest.

```
kubectl apply -f pvc-azurefile-003.yaml

```

## References
### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#provisioner)Provisioner

[https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner](https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner)

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#what-is-azure-files)What is Azure Files?

[https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction)

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#introduction-to-azure-managed-disks)Introduction to Azure managed disks

[https://docs.microsoft.com/en-us/azure/virtual-machines/windows/managed-disks-overview](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/managed-disks-overview)

[https://feedback.azure.com/forums/914020-azure-kubernetes-service-aks/suggestions/35146387-support-non-interactive-login-for-aad-integrated-c](https://feedback.azure.com/forums/914020-azure-kubernetes-service-aks/suggestions/35146387-support-non-interactive-login-for-aad-integrated-c)

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#manually-create-and-use-a-volume-with-azure-disks-in-azure-kubernetes-service-aks)Manually create and use a volume with Azure disks in Azure Kubernetes Service (AKS)

[https://docs.microsoft.com/en-us/azure/aks/azure-disk-volume](https://docs.microsoft.com/en-us/azure/aks/azure-disk-volume)

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#manually-create-and-use-a-volume-with-azure-files-share-in-azure-kubernetes-service-aks)Manually create and use a volume with Azure Files share in Azure Kubernetes Service (AKS)

[https://docs.microsoft.com/en-us/azure/aks/azure-files-volume](https://docs.microsoft.com/en-us/azure/aks/azure-files-volume)

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#dynamically-create-and-use-a-persistent-volume-with-azure-disks-in-azure-kubernetes-service-aks)Dynamically create and use a persistent volume with Azure disks in Azure Kubernetes Service (AKS)

[https://docs.microsoft.com/en-us/azure/aks/azure-disks-dynamic-pv](https://docs.microsoft.com/en-us/azure/aks/azure-disks-dynamic-pv)

### [](https://github.com/tadeugr/aks-references/tree/master/AKS-volumes#dynamically-create-and-use-a-persistent-volume-with-azure-files-in-azure-kubernetes-service-aks)Dynamically create and use a persistent volume with Azure Files in Azure Kubernetes Service (AKS)

[https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv](https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv)
