#!/bin/bash

#source: https://fluxcd.io/flux/get-started/

# Install Flux onto your cluster
# flux bootstrap command: 
# - Creates repo <fleet-infra> in your github account
# - Adds Flux component manifests to the repository
# - Deploys Flux Components to your Kubernetes Cluster.
# - Configures Flux components to track the path /clusters/my-cluster/ in the repository

# Home directory for the flux demo:
cd $HOME/repos/flux_demo

#Install flux: brew install fluxcd/tap/flux
chmod +x flux_prerequisites.sh
./flux_prerequisites.sh

export GITHUB_TOKEN=$(cat $HOME/.pat/gitpat_eyerene14)
export GITHUB_USER=eyerene14

# Install Flux onto your cluster 
echo "Bootstrapping flux to the cluster..."

# Creates the flux-fleet-infra remote repository 
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=flux-fleet-infra \
  --branch=main \
  --path=./clusters/my-cluster \
  --personal

# Clone the flux-fleet-infra repository to your local machine:
cd ..
git clone https://github.com/$GITHUB_USER/flux-fleet-infra
cd flux-fleet-infra
# View remote URL of the flux-fleet-infra repository:
# git remote get-url origin
# git remote set-url origin https://github.com/eyerene14/flux-fleet-infra

# Create a GitRepository manifest pointing to podinfo repository’s master branch:
echo "Creating GitRepository manifest for podinfo..."
# flux create command creates a GitRepository file that points to the podinfo repo
flux create source git podinfo \
  --url=https://github.com/stefanprodan/podinfo \
  --branch=master \
  --interval=1m \
  --export > ./clusters/my-cluster/podinfo-source.yaml

# Commit and push the podinfo-source.yaml file to the flux-gs repository:
git add -A && git commit -m "Add podinfo GitRepository"
git push

# Deploy application: 
# flux create command creates a Kustomization file that applies the podinfo deployment
# create tells Flux to build and apply the kustomize file located in the podinfo repo
echo "Creating kustomization and deploying podinfo app..."

flux create kustomization mypodinfo \
  --target-namespace=default \
  --source=podinfo \
  --path="./kustomize" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/my-cluster/podinfo-kustomization.yaml

# Commit and push the podinfo-kustomization.yaml file to the flux-gs repository:
git add -A && git commit -m "Add podinfo Kustomization"
git push

flux get kustomizations --watch &

echo "Waiting for podinfo app to be deployed..."
kubectl -n default get deployments,services
# Expected output:
# NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
# service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   81m

kubectl -n default get nodes
# Expected output:
# NAME                     STATUS   ROLES           AGE   VERSION
# kiac-dev-control-plane   Ready    control-plane   82m   v1.37.0
# kiac-dev-worker-1        Ready    <none>          82m   v1.37.0
# kiac-dev-worker-2        Ready    <none>          82m   v1.37.0


