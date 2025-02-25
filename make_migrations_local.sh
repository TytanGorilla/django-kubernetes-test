#!/bin/bash

set -e  # Exit if any command fails

echo "📌 Locating Django Pod..."
POD_NAME=$(kubectl get pod -l app=django-app -o jsonpath="{.items[0].metadata.name}")

if [[ -z "$POD_NAME" ]]; then
  echo "❌ Error: No running Django pod found!"
  exit 1
fi

echo "✅ Found running Django pod: $POD_NAME"

# Set the correct path to manage.py inside the container
MANAGE_PY_PATH="/final_project/backend/manage.py"

echo "📌 Running 'makemigrations' inside the Django container..."
kubectl exec -it "$POD_NAME" -- bash -c "python $MANAGE_PY_PATH makemigrations scheduler"

# Ensure we are copying from the correct migrations directory inside the container
CONTAINER_MIGRATIONS_PATH="/final_project/backend/apps/scheduler/migrations"

# Get script's directory for portability (handles Windows Git Bash issues)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_MIGRATIONS_DIR="$SCRIPT_DIR/apps/scheduler/migrations"

echo "📌 Ensuring local migrations directory exists: $LOCAL_MIGRATIONS_DIR"
mkdir -p "$LOCAL_MIGRATIONS_DIR"

# Fix for Windows Git Bash - Convert path format for kubectl
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
  LOCAL_MIGRATIONS_DIR=$(cygpath -w "$LOCAL_MIGRATIONS_DIR")
fi

echo "📌 Copying migration files from container to local machine..."
kubectl exec -it "$POD_NAME" -- ls "$CONTAINER_MIGRATIONS_PATH"

# Copy files individually to avoid kubectl cp directory issues
for FILE in $(kubectl exec "$POD_NAME" -- ls "$CONTAINER_MIGRATIONS_PATH"); do
  echo "📌 Copying $FILE..."
  kubectl cp "$POD_NAME:$CONTAINER_MIGRATIONS_PATH/$FILE" "$LOCAL_MIGRATIONS_DIR/"
done

echo "✅ Migrations have been generated and copied locally for version control."
echo "⚠️ Remember: You still need to run 'python manage.py migrate scheduler' when you're ready to apply them!"