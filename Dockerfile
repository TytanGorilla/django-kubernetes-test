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
    
    # Debug: Verify the React build folder was created
    RUN ls -la /final_project/frontend/build || echo "⚠️ No React build found!"
    
    # ------------------ FINAL IMAGE (Django + Nginx Static Files) ------------------
    FROM backend AS final
    WORKDIR /final_project
    
    # ✅ 1. Copy entire React build (not just static) so Django can reference `asset-manifest.json`
    COPY --from=frontend /final_project/frontend/build/ /final_project/staticfiles/frontend/

    # ✅ 2. Copy React’s build to Nginx's serving directory (for Nginx)
    COPY --from=frontend /final_project/frontend/build/ /usr/share/nginx/html/static/frontend/

    # ✅ 2. Copy React’s built static files to Nginx's serving directory 
    #COPY --from=frontend /final_project/frontend/build/static/ /usr/share/nginx/html/static/
    
    # Debug: Check if frontend static files were copied successfully
    RUN ls -la /usr/share/nginx/html/static/ || echo "⚠️ No frontend assets found!"
    
    # ✅ Copy entrypoint script and ensure it's executable
    COPY entrypoint.sh /entrypoint.sh
    RUN chmod +x /entrypoint.sh
    
    # Install Docker CLI (for Kubernetes support)
    RUN apt-get update && apt-get install -y docker.io && apt-get clean
    
    # Install Kind (Kubernetes IN Docker)
    RUN curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 && \
        chmod +x /usr/local/bin/kind
    
    # Install kubectl
    RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
        chmod +x kubectl && \
        mv kubectl /usr/local/bin/
    
    # Expose the port the app runs on
    EXPOSE 8000
    
    # ✅ Run entrypoint script to collect static files and start the server
    CMD ["bash", "/entrypoint.sh"]    