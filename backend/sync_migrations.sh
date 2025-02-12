#!/bin/bash

# Get running Django pod name dynamically
POD_NAME=$(kubectl get pod -l app=django-app -o jsonpath="{.items[0].metadata.name}")

# Run migrations inside the pod
kubectl exec -it $POD_NAME -- python manage.py makemigrations scheduler
kubectl exec -it $POD_NAME -- python manage.py migrate scheduler

# Copy migrations to the local filesystem
kubectl cp $POD_NAME:/final_project/apps/scheduler/migrations ./apps/scheduler/migrations

echo "✅ Migrations copied locally to apps/scheduler/migrations/. Remember to commit them!"