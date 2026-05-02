#!/usr/bin/env bash
set -euo pipefail

########################################
# USER VARIABLES
########################################
CLUSTER_NAME="homelab-k8s"
WORKER_COUNT=2               # <<< CHANGE THIS
K8S_VERSION="v1.32.0"
API_PORT=6443
SERVER_IP="$(hostname -I | awk '{print $1}')"

########################################
# INSTALL DEPENDENCIES
########################################
sudo apt update -y
sudo apt install -y ca-certificates curl gnupg lsb-release jq

# Docker
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER"
  echo "NOTE: Docker group membership requires a logout/login (or 'newgrp docker') to take effect in the current shell."
fi

# kubectl
if ! command -v kubectl &>/dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
fi

# kind
if ! command -v kind &>/dev/null; then
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
  chmod +x kind
  sudo mv kind /usr/local/bin/kind
fi

########################################
# GENERATE KIND CONFIG
########################################
CONFIG_FILE="/tmp/kind-${CLUSTER_NAME}.yaml"

cat <<EOF > "$CONFIG_FILE"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ${CLUSTER_NAME}
networking:
  apiServerAddress: "0.0.0.0"
  apiServerPort: ${API_PORT}
nodes:
- role: control-plane
  image: kindest/node:${K8S_VERSION}
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
      certSANs:
      - "${SERVER_IP}"
      - "127.0.0.1"
      - "localhost"
EOF

for i in $(seq 1 "${WORKER_COUNT}"); do
cat <<EOF >> "$CONFIG_FILE"
- role: worker
  image: kindest/node:${K8S_VERSION}
EOF
done

########################################
# CREATE CLUSTER
########################################
# Delete any pre-existing cluster with the same name to start fresh
echo "Removing any existing cluster named '${CLUSTER_NAME}' (if present)..."
kind delete cluster --name "${CLUSTER_NAME}" >/dev/null 2>&1 || true
kind create cluster --config "$CONFIG_FILE"

########################################
# EXPORT KUBECONFIG
########################################
mkdir -p ~/.kube
kind export kubeconfig --name "${CLUSTER_NAME}" --kubeconfig ~/.kube/config

# Fix server address so remote kubectl clients can reach the API server.
# SERVER_IP is derived from 'hostname -I' which yields only digits and dots,
# so it is safe to use directly in the sed expression.
sed -i "s|https://0.0.0.0:${API_PORT}|https://${SERVER_IP}:${API_PORT}|g" ~/.kube/config

########################################
# FIREWALL
########################################
sudo ufw allow ${API_PORT}/tcp || true

########################################
# VERIFY
########################################
kubectl get nodes -o wide
