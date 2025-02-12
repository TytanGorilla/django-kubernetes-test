#!/bin/bash
set -e  # Stop the script on errors

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn..."
exec gunicorn project_config.wsgi:application --bind 0.0.0.0:8000