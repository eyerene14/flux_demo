#!/bin/bash

export GITHUB_TOKEN=$(cat ~/.pat/eyerene14_github_pat)
export GITHUB_USER=eyerene14
export GITHUB_REPO=flux-source

cd ../$GITHUB_REPO
# Create a GitRepository manifest pointing to podinfo repository’s master branch:
echo "Creating GitRepository manifest for isk-reloader..."
# flux create command creates a GitRepository file that points to the flux_demo repo
flux create source git isk-reloader \
  --url=https://github.com/eyerene14/isk-reloader/ \
  --branch=main \
  --interval=1m \
  --export > ./clusters/my-cluster/reloader-source.yaml

# Commit and push the isk-reloader-source.yaml file to the isk-reloader repository:
git add -A && git commit -m "Created a flux source that points to isk-reloader repo"
git push

kubectl get all
kubectl get namespaces

# Deploy application: 
# flux create command creates a Kustomization file that applies the isk-reloader deployment
# create tells Flux to build and apply the kustomize file located in the flux_demo repo
echo "Creating kustomization and deploying isk-reloader app..."

flux create kustomization isk-reloader \
  --target-namespace=isk-reloader \
  --source=isk-reloader \
  --path="./isk-reloader" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/my-cluster/reloader-kustomization.yaml

# Commit and push the isk-reloader-kustomization.yaml file to the flux-gs repository:
git add -A && git commit -m "Add isk-reloader Kustomization"
git push

flux get kustomizations --watch &

echo "Waiting for isk-reloader app to be deployed..."
kubectl -n default get deployments,services