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
git add -A && git commit -m "Add flux_demo GitRepository branch wordpress_app as source"
git push

kubectl get all