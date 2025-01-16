#!/bin/bash

# This script generates a Kubernetes Secret manifest named secrets.yaml
# from a .env file. You can customize the filenames as needed.

ENV_FILE=".env"          # The path to your .env file
SECRETS_FILE="k8s/secrets/secrets.yaml"

# Start the secrets.yaml file with the necessary header
cat <<EOF > $SECRETS_FILE
apiVersion: v1
kind: Secret
metadata:
  name: django-app-secrets
  namespace: default
type: Opaque
data:
EOF

# Read each line from the .env file, including the last line
while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip empty lines or comments
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  # Split the line into key and value
  key=$(echo "$line" | cut -d '=' -f 1)
  value=$(echo "$line" | cut -d '=' -f 2-)

  # Debug: Print the key and value being processed
  echo "Processing key: $key, value: $value"

  # Strip leading and trailing quotes
  value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//')

  # Encode the value
  encoded_value=$(echo -n "$value" | base64 --wrap=0)

  # Append to secrets.yaml
  echo "  $key: $encoded_value" >> $SECRETS_FILE
done < "$ENV_FILE"

echo "Secrets have been generated and saved to $SECRETS_FILE."
echo "Apply them with: kubectl apply -f $SECRETS_FILE"
