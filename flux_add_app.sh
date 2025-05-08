#!/bin/bash

echo "Changing directory to flux-gs..."
cd ../flux-gs

# Create a GitRepository manifest pointing to podinfo repository’s master branch:
echo "Creating GitRepository manifest for wordpressapp..."
# flux create command creates a GitRepository file that points to the flux_demo repo
flux create source git wordpressapp \
  --url=https://github.com/eyerene14/flux_demo \
  --branch=wordpress_app \
  --interval=1m \
  --export > ./clusters/my-cluster/wordpressapp-source.yaml

# Commit and push the wordpressapp-source.yaml file to the flux-gs repository:
git add -A && git commit -m "Created a flux source yaml that points to flux_demo wordpress_app branch"
git push

kubectl get all
kubectl get namespaces

# Deploy application: 
# flux create command creates a Kustomization file that applies the wordpressapp deployment
# create tells Flux to build and apply the kustomize file located in the flux_demo repo
echo "Creating kustomization and deploying wordpressapp app..."

flux create kustomization wordpressapp \
  --target-namespace=default \
  --source=wordpressapp \
  --path="./wordpressapp/kustomize" \
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