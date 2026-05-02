# KIND
Kubernetes KIND Cluster Setup for Ubuntu 24.04

## Overview

`kind-cluster-setup.sh` is a single-script solution that installs all required dependencies and provisions a multi-node [KIND](https://kind.sigs.k8s.io/) (Kubernetes IN Docker) cluster on an Ubuntu 24.04 host.

## What the script does

1. **Installs dependencies** – `docker`, `kubectl`, and `kind` (skipped if already present).
2. **Generates a KIND config** – control-plane node with `certSANs` set to the host IP so remote `kubectl` clients work, plus the requested number of worker nodes.
3. **Creates the cluster** – deletes any existing cluster with the same name first, then runs `kind create cluster`.
4. **Exports kubeconfig** – writes `~/.kube/config` and rewrites the server address from `0.0.0.0` to the real host IP.
5. **Opens the firewall** – runs `ufw allow <API_PORT>/tcp` (non-fatal if ufw is not installed).
6. **Verifies** – prints `kubectl get nodes -o wide`.

## Quick start

```bash
# Clone the repo
git clone https://github.com/hardevsanghera/KIND.git
cd KIND

# (Optional) edit the user variables at the top of the script
#   CLUSTER_NAME  – name for the KIND cluster          (default: homelab-k8s)
#   WORKER_COUNT  – number of worker nodes             (default: 2)
#   K8S_VERSION   – Kubernetes image tag               (default: v1.32.0)
#   API_PORT      – kube-apiserver port on the host    (default: 6443)

chmod +x kind-cluster-setup.sh
./kind-cluster-setup.sh
```

## User variables

| Variable | Default | Description |
|---|---|---|
| `CLUSTER_NAME` | `homelab-k8s` | Name given to the KIND cluster |
| `WORKER_COUNT` | `2` | Number of worker nodes to create |
| `K8S_VERSION` | `v1.32.0` | `kindest/node` image tag (see [available tags](https://hub.docker.com/r/kindest/node/tags)) |
| `API_PORT` | `6443` | Host port mapped to the kube-apiserver |

## Requirements

* Ubuntu 24.04 (or compatible Debian-based distro)
* `sudo` privileges
* Internet access (to download Docker, kubectl, and kind)
