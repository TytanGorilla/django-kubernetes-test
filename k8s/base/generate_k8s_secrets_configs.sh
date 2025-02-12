#!/bin/bash

# Enable debug logging
DEBUG=false  # Set to true to see verbose logs

# Define paths
SECRETS_OUTPUT_DIR="k8s/base/secrets"
CONFIGMAP_OUTPUT_DIR="k8s/base/configmaps"
mkdir -p "$SECRETS_OUTPUT_DIR" "$CONFIGMAP_OUTPUT_DIR"

# Autodetect root path incase script is run from a different directory
PROJECT_ROOT=$(dirname "$(realpath "$0")")

# Define environment file locations
declare -A ENV_SECRETS_FILES=(
    ["django"]="$PROJECT_ROOT/.env.secrets"
    ["frontend"]="$PROJECT_ROOT/frontend/.env.secrets"
)

declare -A ENV_CONFIG_FILES=(
    ["django"]="$PROJECT_ROOT/.env.config"
    ["frontend"]="$PROJECT_ROOT/frontend/.env.config"
)

# Set default values (ConfigMaps only)
DEFAULTS=(
    "DJANGO_DEBUG=True"
    "DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,10.1.0.43,*"
)

# Process each application
for APP in "${!ENV_SECRETS_FILES[@]}"; do
    SECRETS_FILE="$SECRETS_OUTPUT_DIR/$APP-secrets.yaml"
    CONFIGMAP_FILE="$CONFIGMAP_OUTPUT_DIR/$APP-config.yaml"
    ENV_SECRETS="${ENV_SECRETS_FILES[$APP]}"
    ENV_CONFIG="${ENV_CONFIG_FILES[$APP]}"

    echo "🔹 Processing: $APP"

    # ✅ Create Secrets YAML (if .env.secrets exists)
    if [[ -f "$ENV_SECRETS" ]]; then
        echo "🔐 Found secrets file: $ENV_SECRETS"
        echo "apiVersion: v1
kind: Secret
metadata:
  name: $APP-secrets
  namespace: default
type: Opaque
data:" > "$SECRETS_FILE"

        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            key=$(echo "$line" | cut -d '=' -f1)
            value=$(echo "$line" | cut -d '=' -f2- | sed -e 's/^"//' -e 's/"$//')
            encoded_value=$(echo -n "$value" | base64 --wrap=0)
            echo "  $key: $encoded_value" >> "$SECRETS_FILE"
        done < "$ENV_SECRETS"
        echo "✅ Secrets saved to $SECRETS_FILE"
    else
        echo "⚠️ No secrets file found for $APP ($ENV_SECRETS). Skipping secrets."
    fi

    # ✅ Create ConfigMap YAML (if .env.config exists)
    if [[ -f "$ENV_CONFIG" ]]; then
        echo "📝 Found config file: $ENV_CONFIG"
        echo "apiVersion: v1
kind: ConfigMap
metadata:
  name: $APP-config
  namespace: default
data:" > "$CONFIGMAP_FILE"

        # Apply default values
        for DEFAULT in "${DEFAULTS[@]}"; do
            KEY=$(echo "$DEFAULT" | cut -d '=' -f1)
            VALUE=$(echo "$DEFAULT" | cut -d '=' -f2-)
            echo "  $KEY: \"$VALUE\"" >> "$CONFIGMAP_FILE"
        done

        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            key=$(echo "$line" | cut -d '=' -f1)
            value=$(echo "$line" | cut -d '=' -f2- | sed -e 's/^"//' -e 's/"$//')
            echo "  $key: \"$value\"" >> "$CONFIGMAP_FILE"
        done < "$ENV_CONFIG"
        echo "✅ ConfigMap saved to $CONFIGMAP_FILE"
    else
        echo "⚠️ No config file found for $APP ($ENV_CONFIG). Skipping config."
    fi
done

echo "🚀 Apply with: kubectl apply -f k8s/base/secrets/ && kubectl apply -f k8s/base/configmaps/"