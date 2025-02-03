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
    
    WORKDIR /final_project/frontend  # ✅ Fixed path to match actual structure
    
    # Copy package files and install dependencies
    COPY frontend/package.json frontend/package-lock.json ./
    RUN npm install
    
    # Copy frontend source files and build React
    COPY frontend/ ./
    RUN npm run build
    
    # ------------------ MERGE FRONTEND INTO DJANGO ------------------
    FROM backend AS final

    WORKDIR /final_project

    # Ensure the STATIC_ROOT directory is created before copying files
    RUN mkdir -p /final_project/staticfiles

    # ✅ Debug: Show frontend build before copying
    RUN ls -l /final_project/frontend/build || echo "BUILD FOLDER MISSING"

    # ✅ First, copy the frontend build explicitly to backend
    COPY --from=frontend /final_project/frontend/build /final_project/frontend/build

    # ✅ Then copy from backend (which now has build/) to staticfiles
    COPY /final_project/frontend/build/. /final_project/staticfiles/frontend/

    # Copy entrypoint script
    COPY entrypoint.sh /entrypoint.sh
    RUN chmod +x /entrypoint.sh

    # Expose the port the app runs on
    EXPOSE 8000

    # Set entrypoint to ensure proper execution order
    CMD ["sh", "/entrypoint.sh"]