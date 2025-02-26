#!/bin/bash

set -e  # Exit on error

echo "📌 Installing Kind..."
mkdir -p ~/.local/bin
curl -Lo ~/.local/bin/kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ~/.local/bin/kind

# Ensure Kind is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
fi

echo "✅ Kind installed successfully!"

echo "🔄 Verifying Kind version..."
kind version

echo "🚀 Creating Kubernetes Cluster..."
kind create cluster --name my-cluster

echo "✅ Kubernetes cluster 'my-cluster' created successfully!"