# KIND
Kubernetes KIND Cluster Setup for Ubuntu 24.04

## Accessing the cluster remotely (laptop → VM)
```bash
scp user@VM_IP:~/.kube/config ~/.kube/kind-homelab
export KUBECONFIG=~/.kube/kind-homelab
kubectl get nodes
```
