#!/bin/bash
set -e  # Exit on error
DATE=$(date +%Y%m%d)

echo "🛠 Building and pushing images..."

echo "⚡ Building backend (Django)..."
docker build --no-cache -t tytan22/django-app:1.0.$DATE backend/
docker push tytan22/django-app:1.0.$DATE

echo "⚡ Building frontend (React)..."
docker build --no-cache \
  --build-arg REACT_APP_SUPABASE_URL=$(grep REACT_APP_SUPABASE_URL frontend/.env.config | cut -d '=' -f2-) \
  --build-arg REACT_APP_SUPABASE_ANON_KEY=$(grep REACT_APP_SUPABASE_ANON_KEY frontend/.env.secrets | cut -d '=' -f2-) \
  -t tytan22/frontend-app:1.0.$DATE frontend/

docker push tytan22/frontend-app:1.0.$DATE

echo "🚀 Applying Kubernetes configurations..."
kubectl apply -f k8s/base/configmaps --recursive
kubectl apply -f k8s/base/secrets --recursive

# ✅ Apply Deployments BEFORE updating images
kubectl apply -f k8s/base/deployments --recursive

echo "⏳ Waiting for deployments to become available..."
sleep 10  # Adjust if needed

echo "🚀 Checking PostgreSQL status..."
if kubectl get pod -l app=postgres -o jsonpath='{.items[0].status.phase}' | grep -q "Failed"; then
  echo "⚠️ PostgreSQL is in a failed state. Forcing PVC reset..."
  kubectl delete pvc postgres-pvc --force --grace-period=0 || echo "❌ Could not delete postgres PVC!"
  sleep 5  # Give it time to reset
  kubectl apply -f k8s/base/pvc/postgres-pvc.yaml
fi

echo "🚀 Restarting PostgreSQL..."
kubectl rollout restart deployment postgres

echo "🚀 Updating Kubernetes deployments..."
if kubectl get deployment django-app &>/dev/null; then
  kubectl set image deployment/django-app django-container=tytan22/django-app:1.0.$DATE
  kubectl patch deployment django-app --type='json' \
    -p="[{'op': 'replace', 'path': '/spec/template/spec/initContainers/0/image', 'value': 'tytan22/django-app:1.0.$DATE'}]"
else
  echo "❌ Deployment django-app not found. Did you apply it correctly?"
fi

if kubectl get deployment frontend &>/dev/null; then
  kubectl set image deployment/frontend frontend=tytan22/frontend-app:1.0.$DATE
else
  echo "❌ Deployment frontend not found. Did you apply it correctly?"
fi

echo "✅ Deployment complete!"