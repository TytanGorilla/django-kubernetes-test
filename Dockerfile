# ------------------ BACKEND (Django) ------------------
    FROM python:3.11-slim AS backend
    WORKDIR /final_project
    
    # Install system dependencies
    RUN apt-get update && apt-get install -y \
        curl \
        nodejs \
        npm \
        build-essential \
        python3-dev \
        default-libmysqlclient-dev \
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
    
    # ------------------ FRONTEND (React) ------------------
    FROM node:18 AS frontend
    WORKDIR /final_project/frontend
    
    # Copy package files and install dependencies
    COPY frontend/package.json frontend/package-lock.json ./
    RUN npm install --silent
    
    # Copy all frontend source files and build the React app
    COPY frontend/ ./
    RUN npm run build
    
    # (Optional Debug) List the contents so you can verify the build folder was created
    RUN ls -la /final_project/frontend
    
    # ------------------ MERGE FRONTEND INTO DJANGO ------------------
    FROM backend AS final
    WORKDIR /final_project
    
    # Ensure the destination directory exists
    RUN mkdir -p /final_project/staticfiles
    
    # Copy the built frontend assets from the frontend stage before collect static runs
    # The trailing slash on the source tells Docker to copy the folder’s contents.
    COPY --from=frontend /final_project/frontend/build/ /final_project/staticfiles/frontend/

    # Debug: Check if the files were copied successfully
    RUN ls -la /final_project/staticfiles/frontend || echo "⚠️ No frontend assets found in /final_project/staticfiles/frontend"
    
    # Copy entrypoint script and ensure it's executable
    COPY entrypoint.sh /entrypoint.sh
    RUN chmod +x /entrypoint.sh

    # Install Docker CLI
    RUN apt-get update && apt-get install -y docker.io && apt-get clean

    # Install Kind (Kubernetes IN Docker)
    RUN curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 && \
    chmod +x /usr/local/bin/kind

    # **Install kubectl**
    RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/
    
    # Expose the port the app runs on
    EXPOSE 8000
    
    # Set entrypoint to ensure proper execution order
    CMD ["bash", "/entrypoint.sh"]