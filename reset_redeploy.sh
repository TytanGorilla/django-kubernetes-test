#!/bin/bash
set -e  # Exit on error

# Function to scale down deployments
scale_down_deployment() {
    local deployment=$1
    echo "🚀 Scaling down $deployment..."
    kubectl scale deployment "$deployment" --replicas=0 || echo "⚠️ $deployment scale down failed"
}

# Function to apply resources (PVCs, ConfigMaps, Secrets, Services, etc.)
apply_resources() {
    local resource_type=$1
    local resource_dir=$2
    echo "🔄 Applying $resource_type..."
    kubectl apply -f "$resource_dir" --recursive || { echo "❌ Failed to apply $resource_type"; exit 1; }
}

# Function to wait for a PVC to be deleted
wait_for_pvc_deletion() {
    local pvc_name=$1
    echo "⏳ Waiting for $pvc_name to be deleted..."
    until ! kubectl get pvc "$pvc_name" &>/dev/null; do
        sleep 5
    done
    echo "✅ $pvc_name deleted successfully!"
}

# Function to forcefully delete a PVC (removing finalizers first)
force_delete_pvc() {
    local pvc_name=$1
    echo "🗑 Patching PVC $pvc_name to remove finalizers..."
    kubectl patch pvc "$pvc_name" -p '{"metadata":{"finalizers":null}}' || echo "⚠️ Failed to patch finalizers on $pvc_name"
    echo "🗑 Force deleting PVC: $pvc_name..."
    kubectl delete pvc "$pvc_name" --ignore-not-found --force --grace-period=0
    wait_for_pvc_deletion "$pvc_name"
}

# Function to restart deployments
restart_deployment() {
    local deployment=$1
    echo "🔄 Rolling out restart for $deployment..."
    kubectl rollout restart deployment "$deployment" || echo "⚠️ Failed to restart $deployment"
}

# Scale down all deployments
scale_down_deployment django-app
scale_down_deployment nginx
scale_down_deployment postgres

# Delete existing deployments (preserving PVCs for now)
echo "🗑 Deleting deployments (preserving PVCs)..."
kubectl delete -f k8s/base/deployments --recursive || echo "⚠️ Deployment deletion encountered issues"

# Check existing PVCs
echo "🔍 Checking existing PVCs..."
kubectl get pvc || echo "⚠️ No PVCs found!"

# Force delete both PVCs to allow manifest changes (with finalizer patch)
force_delete_pvc postgres-pvc
force_delete_pvc staticfiles-pvc

# Reapply PVC manifests
apply_resources "PVCs" "k8s/base/pvc"

# Reapply ConfigMaps & Secrets
apply_resources "ConfigMaps & Secrets" "k8s/base/configmaps"
apply_resources "ConfigMaps & Secrets" "k8s/base/secrets"

# Apply Services
apply_resources "Services" "k8s/base/services"

# Reapply Deployments
apply_resources "Deployments" "k8s/base/deployments"

# Restart deployments to apply changes
restart_deployment postgres
restart_deployment django-app
restart_deployment nginx

echo "🎉 Application successfully reset & redeployed!"