# ------------------ BACKEND (Django) ------------------
    FROM python:3.11-slim AS backend
    WORKDIR /final_project
    
    # Install system dependencies
    RUN apt-get update && apt-get install -y \
        curl \
        build-essential \
        python3-dev \
        libpq-dev \
        rsync \
        bash \
        && apt-get clean
    
    # Copy requirements and install dependencies
    COPY requirements.txt ./
    RUN pip install --no-cache-dir -r requirements.txt
    
    # Copy the entire Django project into the container
    COPY . /final_project
    
    # (Removed: COPY frontend/build /final_project/frontend/build)
    # Django will serve API requests and static files separately.
    
    # Ensure the Python path includes the working directory
    ENV PYTHONPATH=/final_project
    
    # (Optional) Install Kubernetes tools if needed
    RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
        chmod +x kubectl && \
        mv kubectl /usr/local/bin/
    
    # Copy entrypoint script and make it executable
    COPY entrypoint.sh /entrypoint.sh
    RUN chmod +x /entrypoint.sh
    
    # Expose the Django port
    EXPOSE 8000
    
    # Run the entrypoint script to collect static files and start Gunicorn
    CMD ["bash", "/entrypoint.sh"]    