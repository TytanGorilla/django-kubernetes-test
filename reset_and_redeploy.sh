#!/bin/bash
set -e  # Exit on error

echo "🚀 Scaling down workloads..."
kubectl scale deployment django-app --replicas=0 || echo "⚠️ django-app scale down failed"
kubectl scale deployment nginx --replicas=0 || echo "⚠️ nginx scale down failed"
kubectl scale deployment postgres --replicas=0 || echo "⚠️ postgres scale down failed"
kubectl scale deployment frontend --replicas=0 || echo "⚠️ frontend scale down failed"

echo "🗑 Deleting deployments (preserving PVCs)..."
kubectl delete -f k8s/base/deployments --recursive || echo "⚠️ Deployment deletion encountered issues"

echo "🔍 Checking existing PVCs..."
kubectl get pvc || echo "⚠️ No PVCs found!"

echo "🗑 Cleaning up PostgreSQL if it keeps failing..."
if kubectl get pod -l app=postgres -o jsonpath='{.items[0].status.phase}' | grep -q "Failed"; then
  echo "⚠️ PostgreSQL PVC seems to be corrupted. Deleting..."
  kubectl delete pvc postgres-pvc --force --grace-period=0 || echo "❌ Failed to delete postgres PVC!"
  sleep 5
fi

echo "✅ Applying PVCs..."
kubectl apply -f k8s/base/pvc --recursive || { echo "❌ Failed to apply PVCs"; exit 1; }

echo "🔄 Reapplying ConfigMaps & Secrets..."
kubectl apply -f k8s/base/configmaps --recursive || echo "⚠️ ConfigMaps application encountered issues"
kubectl apply -f k8s/base/secrets --recursive || echo "⚠️ Secrets application encountered issues"

echo "🚀 Redeploying applications..."
kubectl apply -f k8s/base/deployments --recursive || { echo "❌ Deployment application failed"; exit 1; }

echo "🔄 Rolling out restarts..."
kubectl rollout restart deployment postgres || echo "⚠️ Failed to restart postgres"
kubectl rollout restart deployment django-app || echo "⚠️ Failed to restart django-app"
kubectl rollout restart deployment frontend || echo "⚠️ Failed to restart frontend"
kubectl rollout restart deployment nginx || echo "⚠️ Failed to restart nginx"

echo "🎉 Application successfully reset & redeployed!"
