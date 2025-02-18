#!/bin/bash
set -e  # Exit on any error

# Generate a dynamic tag based on the current date (YYYYMMDD)
DATE=$(date +%Y%m%d)
echo "🚀 New image tag: 1.0.$DATE"

#######################################
# Fetch Kubernetes Secrets and Configs
#######################################

echo "🔄 Fetching Kubernetes secrets and config maps..."

# Fetch the values from Kubernetes secrets and configs
export REACT_APP_SUPABASE_URL=$(kubectl get secret consolidated-secrets -o=jsonpath='{.data.REACT_APP_SUPABASE_URL}' | base64 --decode)
export REACT_APP_SUPABASE_ANON_KEY=$(kubectl get secret consolidated-secrets -o=jsonpath='{.data.REACT_APP_SUPABASE_ANON_KEY}' | base64 --decode)

export REACT_APP_BACKEND_URL=$(kubectl get configmap consolidated-config -o=jsonpath='{.data.REACT_APP_BACKEND_URL}')
export PUBLIC_URL=$(kubectl get configmap consolidated-config -o=jsonpath='{.data.PUBLIC_URL}')

echo "🔄 Values fetched: Supabase URL and keys, Backend URL, Public URL."

#######################################
# Build and Push Docker Image (Django + Nginx Consolidated)
#######################################

echo "⚡ Building consolidated Django app (includes Nginx)..."

# Pass the Kubernetes secrets and config values to the Docker build command
docker build --no-cache \
  --build-arg REACT_APP_SUPABASE_URL=$REACT_APP_SUPABASE_URL \
  --build-arg REACT_APP_SUPABASE_ANON_KEY=$REACT_APP_SUPABASE_ANON_KEY \
  --build-arg REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL \
  --build-arg PUBLIC_URL=$PUBLIC_URL \
  -t tytan22/django-app:1.0.$DATE .

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
