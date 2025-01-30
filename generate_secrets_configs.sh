#!/bin/bash

ENV_FILE=".env"
SECRETS_FILE="k8s/base/secrets/secrets.yaml"
CONFIGMAP_FILE="k8s/base/configmaps/django-config.yaml"
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
)

CONFIG_KEYS=(
  "DJANGO_DEBUG"
  "DJANGO_ALLOWED_HOSTS"
)

# Default values for DJANGO_DEBUG and DJANGO_ALLOWED_HOSTS
DEFAULT_DJANGO_DEBUG="True"
DEFAULT_DJANGO_ALLOWED_HOSTS="localhost,127.0.0.1,10.1.0.43,*"

# Ensure required folders exist
mkdir -p k8s/base/secrets k8s/base/configmaps

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
  name: django-config
  namespace: default
data:
  DJANGO_DEBUG: "$DEFAULT_DJANGO_DEBUG"
  DJANGO_ALLOWED_HOSTS: "$DEFAULT_DJANGO_ALLOWED_HOSTS"
EOF

# Process .env for Secrets and ConfigMap
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
  elif [[ " ${CONFIG_KEYS[@]} " =~ " $key " ]]; then
    echo "  $key: \"$value\"" >> $CONFIGMAP_FILE
  fi
done < "$ENV_FILE"

echo "Secrets have been saved to $SECRETS_FILE."
echo "ConfigMap has been saved to $CONFIGMAP_FILE."
echo "Apply them with: kubectl apply -f $SECRETS_FILE && kubectl apply -f $CONFIGMAP_FILE"