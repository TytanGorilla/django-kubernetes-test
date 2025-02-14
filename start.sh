#!/bin/bash
set -e  # Stop the script on errors

echo "Starting Gunicorn..."
# Start Gunicorn in the background
gunicorn project_config.wsgi:application --bind 127.0.0.1:8000 &

echo "Starting Nginx..."
# Start Nginx in the foreground
nginx -g 'daemon off;'