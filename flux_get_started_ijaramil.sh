#!/bin/bash

#source: https://fluxcd.io/flux/get-started/

#Install flux: brew install fluxcd/tap/flux

export GITHUB_TOKEN=$(cat ~/.pat/github_pat)
export GITHUB_USER=ijaramil
export GITHUB_REPO=flux-gs

# Install Flux onto your cluster
# flux bootstrap command: 
# - Creates repo <fleet-infra> in your github account
# - Adds Flux component manifests to the repository
# - Deploys Flux Components to your Kubernetes Cluster.
# - Configures Flux components to track the path /clusters/my-cluster/ in the repository

echo "Bootstrapping flux to the cluster..."

#flux bootstrap github \
#  --owner=$GITHUB_USER \
#  --repository=$GITHUB_REPO \
#  --branch=main \
#  --path=./clusters/my-cluster \
#  --personal

flux bootstrap github --owner=$GITHUB_USER --repository=$GITHUB_REPO --private=false --hostname=scm.starbucks.com --token-auth --path=clusters/my-cluster --personal


# Clone the flux-gs repository to your local machine:
echo "Cloning the flux-gs repository and changing directory..."
cd ..
git clone https://scm.starbucks.com/$GITHUB_USER/flux-gs
cd flux-gs

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


