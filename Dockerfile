# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /final_project

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && apt-get clean

# Copy the requirements file into the image
COPY requirements.txt /final_project/

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project into the container
COPY . /final_project

# Ensure the Python path includes the working directory
ENV PYTHONPATH=/final_project

# Create the STATIC_ROOT directory
RUN mkdir -p /final_project/staticfiles

# Make sure the script is executable
RUN chmod +x /final_project/copy_static_to_docs.sh

# Expose the port the app runs on
EXPOSE 8000

# Set the CMD to run the application and automate the script
CMD python manage.py collectstatic --noinput && \
    bash /final_project/copy_static_to_docs.sh && \
    gunicorn project_config.wsgi:application --bind 0.0.0.0:8000
