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
    
    # Copy the requirements file and install Python dependencies
    COPY requirements.txt /final_project/
    RUN pip install --no-cache-dir -r requirements.txt
    
    # Copy the entire project into the container
    COPY . /final_project
    
    # Ensure the Python path includes the working directory
    ENV PYTHONPATH=/final_project
    
    # ✅ Keep Docker CLI and Kubernetes tools for Kubernetes support
    RUN apt-get update && apt-get install -y docker.io && apt-get clean
    
    RUN curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 && \
        chmod +x /usr/local/bin/kind
    
    RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
        chmod +x kubectl && \
        mv kubectl /usr/local/bin/
    
    # ✅ Copy entrypoint script and ensure it's executable
    COPY entrypoint.sh /entrypoint.sh
    RUN chmod +x /entrypoint.sh
    
    # Expose the port the app runs on
    EXPOSE 8000
    
    # ✅ Run entrypoint script to collect static files and start the server
    CMD ["bash", "/entrypoint.sh"]
    