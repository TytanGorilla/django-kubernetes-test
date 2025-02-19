#!/bin/bash
set -e  # Stop the script on errors

echo "Starting Gunicorn..."
# Start Gunicorn in the background
export PYTHONPATH=/final_project/backend:$PYTHONPATH
gunicorn project_config.wsgi:application --bind 0.0.0.0:8000 &

echo "Starting Nginx..."
# Start Nginx in the foreground
nginx -g 'daemon off;'