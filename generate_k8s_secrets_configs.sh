#!/bin/bash

# Enable debug logging
DEBUG=false  # Set to true to see verbose logs

# Define output directories
SECRETS_OUTPUT_DIR="k8s/base/secrets"
CONFIGMAP_OUTPUT_DIR="k8s/base/configmaps"
mkdir -p "$SECRETS_OUTPUT_DIR" "$CONFIGMAP_OUTPUT_DIR"

# Autodetect project root (in case script is run from a different directory)
PROJECT_ROOT=$(dirname "$(realpath "$0")")
BACKEND_ENV_DIR="$PROJECT_ROOT/backend"
FRONTEND_ENV_DIR="$PROJECT_ROOT/frontend"

# Define environment file locations
declare -A ENV_SECRETS_FILES=(
    ["django"]="$BACKEND_ENV_DIR/.env.secrets"
    ["frontend"]="$FRONTEND_ENV_DIR/.env.secrets"
)

declare -A ENV_CONFIG_FILES=(
    ["django"]="$BACKEND_ENV_DIR/.env.config"
    ["frontend"]="$FRONTEND_ENV_DIR/.env.config"
)

# Generate Build Version (Timestamp-based, to ensure cache-busting)
BUILD_VERSION=$(date +%s)

# Update frontend/.env.config to replace $(date +%s) with the build version
if [[ -f "$FRONTEND_ENV_DIR/.env.config" ]]; then
    echo "🔄 Updating frontend/.env.config with Build Version: $BUILD_VERSION"
    sed -i "s|\$(date +%s)|$BUILD_VERSION|g" "$FRONTEND_ENV_DIR/.env.config"
fi

# Set default values for Django (to be included in the config map)
declare -A DEFAULTS=(
    ["DJANGO_DEBUG"]="True"
    ["DJANGO_ALLOWED_HOSTS"]="localhost,127.0.0.1,10.1.0.43,*"
)

#############################################
# Create a consolidated Secrets YAML file  #
#############################################

CONSOLIDATED_SECRETS_FILE="$SECRETS_OUTPUT_DIR/consolidated-secrets.yaml"

echo "apiVersion: v1
kind: Secret
metadata:
  name: consolidated-secrets
  namespace: default
type: Opaque
data:" > "$CONSOLIDATED_SECRETS_FILE"

for APP in "${!ENV_SECRETS_FILES[@]}"; do
    SECRETS_PATH="${ENV_SECRETS_FILES[$APP]}"
    if [[ -f "$SECRETS_PATH" ]]; then
        echo "🔐 Processing secrets for: $APP from $SECRETS_PATH"
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip empty lines and comments
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            key=$(echo "$line" | cut -d '=' -f1)
            value=$(echo "$line" | cut -d '=' -f2- | sed -e 's/^"//' -e 's/"$//')
            encoded_value=$(echo -n "$value" | base64 --wrap=0)
            echo "  $key: $encoded_value" >> "$CONSOLIDATED_SECRETS_FILE"
        done < "$SECRETS_PATH"
    else
        echo "⚠️ No secrets file found for $APP ($SECRETS_PATH). Skipping secrets."
    fi
done

echo "✅ Consolidated secrets saved to $CONSOLIDATED_SECRETS_FILE"

#############################################
# Create a consolidated ConfigMap YAML file #
#############################################

CONSOLIDATED_CONFIGMAP_FILE="$CONFIGMAP_OUTPUT_DIR/consolidated-config.yaml"
echo "apiVersion: v1
kind: ConfigMap
metadata:
  name: consolidated-config
  namespace: default
data:" > "$CONSOLIDATED_CONFIGMAP_FILE.tmp"

# If the Django config exists, add its defaults first
if [[ -f "${ENV_CONFIG_FILES["django"]}" ]]; then
    echo "📝 Adding Django defaults to consolidated config"
    for KEY in "${!DEFAULTS[@]}"; do
        VALUE="${DEFAULTS[$KEY]}"
        echo "  $KEY: \"$VALUE\"" >> "$CONSOLIDATED_CONFIGMAP_FILE.tmp"
    done
fi

for APP in "${!ENV_CONFIG_FILES[@]}"; do
    CONFIG_PATH="${ENV_CONFIG_FILES[$APP]}"
    if [[ -f "$CONFIG_PATH" ]]; then
        echo "📝 Processing config for: $APP from $CONFIG_PATH"
        # Track if REACT_APP_BUILD_VERSION is found for the frontend
        BUILD_VERSION_FOUND=false
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            key=$(echo "$line" | cut -d '=' -f1)
            value=$(echo "$line" | cut -d '=' -f2- | sed -e 's/^"//' -e 's/"$//')
            
            # For frontend, ensure REACT_APP_BUILD_VERSION uses the BUILD_VERSION
            if [[ "$key" == "REACT_APP_BUILD_VERSION" && "$APP" == "frontend" ]]; then
                value="$BUILD_VERSION"
                BUILD_VERSION_FOUND=true
            fi

            echo "  $key: \"$value\"" >> "$CONSOLIDATED_CONFIGMAP_FILE.tmp"
        done < "$CONFIG_PATH"
        if [[ "$APP" == "frontend" && "$BUILD_VERSION_FOUND" == false ]]; then
            echo "  REACT_APP_BUILD_VERSION: \"$BUILD_VERSION\"" >> "$CONSOLIDATED_CONFIGMAP_FILE.tmp"
        fi
    else
        echo "⚠️ No config file found for $APP ($CONFIG_PATH). Skipping config."
    fi
done

mv "$CONSOLIDATED_CONFIGMAP_FILE.tmp" "$CONSOLIDATED_CONFIGMAP_FILE"
echo "✅ Consolidated config map saved to $CONSOLIDATED_CONFIGMAP_FILE"

echo "🚀 Apply with: kubectl apply -f k8s/base/secrets/ && kubectl apply -f k8s/base/configmaps/"