#!/bin/bash
DATE=$(date +%Y%m%d)

echo "🛠 Building and pushing images..."
docker build --no-cache -t tytan22/django-app:1.0.$DATE backend/
docker push tytan22/django-app:1.0.$DATE

docker build --no-cache \
  --build-arg REACT_APP_SUPABASE_URL=$(grep REACT_APP_SUPABASE_URL frontend/.env.config | cut -d '=' -f2-) \
  --build-arg REACT_APP_SUPABASE_ANON_KEY=$(grep REACT_APP_SUPABASE_ANON_KEY frontend/.env.secrets | cut -d '=' -f2-) \
  -t tytan22/frontend-app:1.0.$DATE frontend/

docker push tytan22/frontend-app:1.0.$DATE

echo "🚀 Updating Kubernetes deployments..."
# ✅ Update Django main container
kubectl set image deployment/django-app django-container=tytan22/django-app:1.0.$DATE

# ✅ Update Django initContainer (migrate)
kubectl patch deployment django-app --type='json' -p="[{'op': 'replace', 'path': '/spec/template/spec/initContainers/0/image', 'value': 'tytan22/django-app:1.0.$DATE'}]"

# ✅ Update Frontend container
kubectl set image deployment/frontend frontend=tytan22/frontend-app:1.0.$DATE