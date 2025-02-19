# ------------------ Stage 1: Build React Frontend ------------------
    FROM node:18 AS frontend
    WORKDIR /final_project/frontend
    
    # Copy package files and install dependencies
    COPY frontend/package.json frontend/package-lock.json ./
    RUN npm install --silent
    
    # Build-time args for environment variables
    ARG REACT_APP_SUPABASE_URL
    ARG REACT_APP_SUPABASE_ANON_KEY
    ARG REACT_APP_BACKEND_URL
    
    ENV REACT_APP_SUPABASE_URL=${REACT_APP_SUPABASE_URL}
    ENV REACT_APP_SUPABASE_ANON_KEY=${REACT_APP_SUPABASE_ANON_KEY}
    ENV REACT_APP_BACKEND_URL=${REACT_APP_BACKEND_URL}
    
    # Copy frontend source and build the React app
    COPY frontend/ ./
    
    RUN REACT_APP_SUPABASE_URL=$REACT_APP_SUPABASE_URL \
        REACT_APP_SUPABASE_ANON_KEY=$REACT_APP_SUPABASE_ANON_KEY \
        REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL \
        npm run build --verbose || (echo "⚠️ React build failed!" && exit 1)
    
    # ------------------ Stage 2: Build Django Backend ------------------
    FROM python:3.11-slim AS backend
    
    # Set correct root directory before copying backend
    WORKDIR /final_project/backend
    
    # Install system dependencies required by Django
    RUN apt-get update && apt-get install -y \
        build-essential \
        python3-dev \
        libpq-dev \
        curl \
        rsync \
        bash \
        && apt-get clean
    
    # Copy requirements and install Python dependencies
    COPY backend/requirements.txt ./
    RUN pip install --no-cache-dir -r requirements.txt
    
    # Copy the entire backend project (preserving structure) # Ensures backend structure is copied correctly
    COPY backend /final_project/backend/
    
    # Set the environment variable for STATIC_ROOT during build
    ENV STATIC_ROOT=/final_project/global_static
    
    # Run collectstatic to collect the static files to the specified directory
    RUN python manage.py collectstatic --noinput && ls -al $STATIC_ROOT
    
    # ------------------ Stage 3: Final Image with Both Services ------------------
    FROM python:3.11-slim
    
    # Install system packages including Nginx
    RUN apt-get update && apt-get install -y nginx && apt-get clean
    
    # Copy Python dependencies from backend build stage
    COPY --from=backend /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
    COPY --from=backend /usr/local/bin /usr/local/bin
    
    # Copy the React build output to Nginx’s folder
    COPY --from=frontend /final_project/frontend/build /usr/share/nginx/html/frontend-static/
    
    # Copy the asset manifest from React build into Django static directory
    COPY --from=frontend /final_project/frontend/build/asset-manifest.json /final_project/static/manifest/
    
    # Copy the collected static files from the local filesystem (where collectstatic placed them)
    COPY --from=backend /final_project/global_static/ /usr/share/nginx/html/global_static/
    
    # Copy the entire Django backend project (for Gunicorn to use)
    COPY --from=backend /final_project/backend /final_project/backend/
    
    # Expose ports (80 for Nginx, 8000 for Django)
    EXPOSE 80 8000
    
    # Copy a startup script that runs Gunicorn and then Nginx
    COPY start.sh /start.sh
    RUN chmod +x /start.sh
    
    # Use the startup script as the container command
    CMD ["/start.sh"]
    