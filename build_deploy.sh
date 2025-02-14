#!/bin/bash
set -e  # Exit on any error

# Generate a dynamic tag based on the current date (YYYYMMDD)
DATE=$(date +%Y%m%d)
echo "🚀 New image tag: 1.0.$DATE"

#######################################
# Build and Push Docker Image (Django + Nginx Consolidated)
#######################################

echo "⚡ Building consolidated Django app (includes Nginx)..."
docker build --no-cache -t tytan22/django-app:1.0.$DATE .
docker push tytan22/django-app:1.0.$DATE

#######################################
# Update Deployment YAML Files with New Image Tags
#######################################

echo "🔄 Updating deployment YAML files with new image tags..."

# Update the Django deployment YAML
sed -i "s|tytan22/django-app:1\.0\.[0-9]*|tytan22/django-app:1.0.$DATE|g" k8s/base/deployments/django-deployment.yaml

# Update the Nginx deployment YAML (since it also uses the same Django app image)
sed -i "s|tytan22/django-app:1\.0\.[0-9]*|tytan22/django-app:1.0.$DATE|g" k8s/base/deployments/nginx-deployment.yaml

#######################################
# Apply Kubernetes Manifests
#######################################

echo "🚀 Applying PVCs..."
kubectl apply -f k8s/base/pvc --recursive

echo "🚀 Applying ConfigMaps & Secrets..."
kubectl apply -f k8s/base/configmaps --recursive
kubectl apply -f k8s/base/secrets --recursive

echo "🚀 Applying Services..."
kubectl apply -f k8s/base/services --recursive

echo "🚀 Applying updated Deployments..."
kubectl apply -f k8s/base/deployments --recursive

#######################################
# Restart Deployments (Optional, for a full rollout)
#######################################

echo "⏳ Rolling out restarts..."
kubectl rollout restart deployment postgres
kubectl rollout restart deployment django-app
kubectl rollout restart deployment nginx  # ✅ Restored, since it also uses django-app image

#######################################
# Final Status
#######################################

echo "✅ Deployment complete! New images:"
kubectl get deployment django-app -o jsonpath="{.spec.template.spec.containers[*].image}" && echo ""
kubectl get deployment nginx -o jsonpath="{.spec.template.spec.containers[*].image}" && echo ""