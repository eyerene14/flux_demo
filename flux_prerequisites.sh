#!/bin/bash

# Local Kubernetes Cluster setup for flux installation on Mac using kiac
# ----------------------------------------------
# Running a local Kubernetes cluster on a Mac using kiac:
# kiac is a tool that allows you to run a local Kubernetes cluster on your Mac using apple/container. 
# No Docker Desktop. No Lima. No QEMU.
# source: https://github.com/saiyam1814/kiac

  
if brew list --cask saiyam1814/tap/kiac > /dev/null; then
  echo "kiac IS installed" 
  
  set -x
  # Check your Kubernetes cluster is running:
  kiac get cluster
  set +x
else
  echo "Installing kiac from homebrew..."
  brew install --cask saiyam1814/tap/kiac

  set -x
  echo "Checking your apple/container setup..."
  kiac doctor

  # Potential errors and solutions: 
    # ⬢ ✗ apple/container CLI 1.7.1
      # Install apple/container CLI from https://github.com/apple/container/releases
      # 1. Download: container-1.7.1-installer-signed.pkg
      # 2. Run kiac doctor: kiac doctor --fix
    # ⬢ ✗ container system service stopped - kiac will start it automatically on create, or run: kiac doctor --fix
  set +x

  # Creates a cluster with 1 control plane + 2 workers
  kiac create cluster --name dev --workers 2   --observability --gateway 
fi

# Flux installation on Mac local Kubernetes cluster using kiac
# ----------------------------------------------
# source: https://fluxcd.io/flux/get-started/

if brew list --versions fluxcd/tap/flux > /dev/null; then
  echo "Flux IS installed" 
  # Check your Kubernetes cluster & everything needed to run Flux:
  flux check --pre
  # Expected output:
    # ► checking prerequisites
    # ✔ kubernetes 1.28.0 >=1.25.0
    # ✔ prerequisites checks passed
else
  echo "Flux NOT installed"
  echo "Installing flux from homebrew..."
  brew install fluxcd/tap/flux
fi