#!/bin/bash

# Enable debug logging
DEBUG=false  # Set to true to see verbose logs

# Define paths
SECRETS_OUTPUT_DIR="k8s/base/secrets"
CONFIGMAP_OUTPUT_DIR="k8s/base/configmaps"
mkdir -p "$SECRETS_OUTPUT_DIR" "$CONFIGMAP_OUTPUT_DIR"

# Autodetect root path in case script is run from a different directory
PROJECT_ROOT=$(dirname "$(realpath "$0")")
BACKEND_ENV_DIR="$PROJECT_ROOT/backend"  # ✅ Updated backend path
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

# ✅ Generate Build Version (Timestamp-based, to ensure cache-busting)
BUILD_VERSION=$(date +%s)

# ✅ Directly modify frontend/.env.config so it no longer contains `$(date +%s)`
if [[ -f "$FRONTEND_ENV_DIR/.env.config" ]]; then
    echo "🔄 Updating frontend/.env.config with Build Version: $BUILD_VERSION"
    sed -i "s|\$(date +%s)|$BUILD_VERSION|g" "$FRONTEND_ENV_DIR/.env.config"
fi

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

        # ✅ Track if REACT_APP_BUILD_VERSION is already found
        BUILD_VERSION_FOUND=false
        TEMP_CONFIG_FILE="${CONFIGMAP_FILE}.tmp"

        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            key=$(echo "$line" | cut -d '=' -f1)
            value=$(echo "$line" | cut -d '=' -f2- | sed -e 's/^"//' -e 's/"$//')

            # ✅ If it's REACT_APP_BUILD_VERSION, replace value with timestamp
            if [[ "$key" == "REACT_APP_BUILD_VERSION" && "$APP" == "frontend" ]]; then
                value="$BUILD_VERSION"
                BUILD_VERSION_FOUND=true
            fi

            echo "  $key: \"$value\"" >> "$TEMP_CONFIG_FILE"
        done < "$ENV_CONFIG"

        # ✅ Ensure REACT_APP_BUILD_VERSION is only added once to frontend-config.yaml
        if [[ "$APP" == "frontend" && "$BUILD_VERSION_FOUND" == false ]]; then
            echo "  REACT_APP_BUILD_VERSION: \"$BUILD_VERSION\"" >> "$TEMP_CONFIG_FILE"
        fi

        mv "$TEMP_CONFIG_FILE" "$CONFIGMAP_FILE"  # Replace original file with modified version

        echo "✅ ConfigMap saved to $CONFIGMAP_FILE"
    else
        echo "⚠️ No config file found for $APP ($ENV_CONFIG). Skipping config."
    fi
done

echo "🚀 Apply with: kubectl apply -f k8s/base/secrets/ && kubectl apply -f k8s/base/configmaps/"