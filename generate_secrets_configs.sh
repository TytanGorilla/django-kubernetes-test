#!/bin/bash

ENV_FILE=".env"
SECRETS_FILE="k8s/secrets/secrets.yaml"
CONFIGMAP_FILE="k8s/configs/configmap.yaml"
DEBUG=false

# Define keys for Secrets and ConfigMap
SECRET_KEYS=(
  "DJANGO_SECRET_KEY"
  "POSTGRES_DB"
  "POSTGRES_USER"
  "POSTGRES_PASSWORD"
  "POSTGRES_HOST"
  "POSTGRES_PORT"
  "DATABASE_URL"
  "DJANGO_DEBUG"
  "DJANGO_ALLOWED_HOSTS"
)
CONFIG_KEYS=(
  "STORAGE_PATH"
  "APP_MODE"
)

# Detect Environment
if [[ -n "$CODESPACES" || -n "$GITHUB_CODESPACES" ]]; then
  ENVIRONMENT="codespaces"
  STORAGE_PATH="/tmp/postgres"  # Use ephemeral storage in Codespaces
  echo "Running in Codespaces environment. Setting STORAGE_PATH to $STORAGE_PATH."
else
  ENVIRONMENT="local"
  STORAGE_PATH="/data/postgres"  # Use local storage for local environments
  echo "Running in local environment. Setting STORAGE_PATH to $STORAGE_PATH."
fi

# Write dynamic STORAGE_PATH to .env (optional)
if ! grep -q "^STORAGE_PATH=" "$ENV_FILE"; then
  echo "STORAGE_PATH=$STORAGE_PATH" >> "$ENV_FILE"
  echo "Added STORAGE_PATH to $ENV_FILE: $STORAGE_PATH"
fi

# Start generating Kubernetes manifests
mkdir -p k8s/secrets k8s/configs

# Generate Secrets YAML
echo "Generating Kubernetes Secret..."
cat <<EOF > $SECRETS_FILE
apiVersion: v1
kind: Secret
metadata:
  name: django-app-secrets
  namespace: default
type: Opaque
data:
EOF

# Generate ConfigMap YAML
echo "Generating Kubernetes ConfigMap..."
cat <<EOF > $CONFIGMAP_FILE
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  STORAGE_PATH: "$STORAGE_PATH"
EOF

# Process .env for Secrets
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  key=$(echo "$line" | cut -d '=' -f 1)
  value=$(echo "$line" | cut -d '=' -f 2-)
  value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')

  if [[ $DEBUG == true ]]; then
    echo "Processing key: $key"
  fi

  if [[ " ${SECRET_KEYS[@]} " =~ " $key " ]]; then
    encoded_value=$(echo -n "$value" | base64 --wrap=0)
    echo "  $key: $encoded_value" >> $SECRETS_FILE
  fi
done < "$ENV_FILE"

echo "Secrets have been saved to $SECRETS_FILE."
echo "ConfigMap has been saved to $CONFIGMAP_FILE."
echo "Apply them with: kubectl apply -f $SECRETS_FILE && kubectl apply -f $CONFIGMAP_FILE"
