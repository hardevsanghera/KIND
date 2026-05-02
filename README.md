# KIND
Kubernetes KIND Cluster Setup for Ubuntu 24.04

## What it does

`kind-cluster-setup.sh` automates the creation of a local multi-node [Kubernetes IN Docker (KIND)](https://kind.sigs.k8s.io/) cluster on Ubuntu 24.04. It:

- Installs the required dependencies: Docker, `kubectl`, and `kind` (skipping any that are already present).
- Creates a KIND cluster with one control-plane node and a configurable number of worker nodes.
- Exposes the Kubernetes API server on the host's primary IP address so that remote `kubectl` clients can reach it.
- Exports the kubeconfig to `~/.kube/config` and opens the API server port in UFW.
- Verifies the cluster is healthy by running `kubectl get nodes`.

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/hardevsanghera/KIND.git
   cd KIND
   ```

2. **Customise the script** (optional) – open `kind-cluster-setup.sh` and adjust the variables near the top:
   | Variable | Default | Description |
   |---|---|---|
   | `CLUSTER_NAME` | `homelab-k8s` | Name of the KIND cluster |
   | `WORKER_COUNT` | `2` | Number of worker nodes |
   | `K8S_VERSION` | `v1.32.0` | Kubernetes node image version |
   | `API_PORT` | `6443` | Port the API server listens on |

3. **Make the script executable and run it**
   ```bash
   chmod +x kind-cluster-setup.sh
   ./kind-cluster-setup.sh
   ```
   > **Note:** If Docker is newly installed by the script, you will need to log out and back in (or run `newgrp docker`) before Docker commands work without `sudo`.

4. **Verify the cluster**
   ```bash
   kubectl get nodes -o wide
   ```
   All nodes should reach the `Ready` state within a minute or two.

5. **Delete the cluster when finished**
   ```bash
   kind delete cluster --name homelab-k8s
   ```
