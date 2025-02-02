#!/bin/sh
set -e  # Stop the script on errors

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Running static file sync script..."
bash /final_project/copy_static_to_docs.sh

echo "Starting Gunicorn..."
exec gunicorn project_config.wsgi:application --bind 0.0.0.0:8000