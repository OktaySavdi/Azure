![image](https://github.com/OktaySavdi/Azure/assets/3519706/76683054-882c-4a18-8bef-bdeaa72b69d8)
[https://learn.microsoft.com/en-us/azure/aks/node-access#configure-virtual-machine-scale-set-based-aks-clusters-for-ssh-access](https://learn.microsoft.com/en-us/azure/aks/node-access#configure-virtual-machine-scale-set-based-aks-clusters-for-ssh-access)

To create an interactive shell connection to a Linux node, use the kubectl debug command to run a privileged container on your node. To list your nodes, use the kubectl get nodes command:
```
kubectl get nodes -o wide
```
Us the kubectl debug command to run a container image on the node to connect to it.
```
kubectl debug node/aks-nodepool1-12345678-vmss000000 -it --image=mcr.microsoft.com/dotnet/runtime-deps:6.0
```
```
chroot /host
bash
```
