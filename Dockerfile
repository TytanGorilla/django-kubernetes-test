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
    
    # Set working directory for the frontend stage
    WORKDIR /final_project/frontend
    
    # Copy package files and install dependencies
    COPY frontend/package.json frontend/package-lock.json ./
    RUN npm install
    
    # Copy the rest of the frontend source files and build React
    COPY frontend/ ./
    RUN npm run build
    
    # Debug: List files so we can verify the build folder is created.
    RUN ls -la
    
    # ------------------ MERGE FRONTEND INTO DJANGO ------------------
    FROM backend AS final
    
    WORKDIR /final_project
    
    # Create the destination directory for static files
    RUN mkdir -p /final_project/staticfiles/frontend
    
    # Copy the built frontend assets from the frontend stage.
    # Here we use a relative path ("build") which refers to
    # /final_project/frontend/build in the frontend stage.
    COPY --from=frontend build/. /final_project/staticfiles/frontend/
    
    # Copy entrypoint script and ensure it's executable
    COPY entrypoint.sh /entrypoint.sh
    RUN chmod +x /entrypoint.sh
    
    # Expose the port the app runs on
    EXPOSE 8000
    
    # Set entrypoint to ensure proper execution order
    CMD ["sh", "/entrypoint.sh"]    