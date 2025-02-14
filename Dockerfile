# Stage 1: Build React Frontend
FROM node:18 AS frontend
WORKDIR /frontend
# Copy package files and install dependencies
COPY package.json package-lock.json ./
RUN npm install --silent
# Build-time args for environment variables
ARG REACT_APP_BUILD_VERSION
ARG REACT_APP_SUPABASE_URL
ARG REACT_APP_SUPABASE_ANON_KEY
ARG REACT_APP_BACKEND_URL
ARG PUBLIC_URL
ENV REACT_APP_BUILD_VERSION=${REACT_APP_BUILD_VERSION}
ENV REACT_APP_SUPABASE_URL=${REACT_APP_SUPABASE_URL}
ENV REACT_APP_SUPABASE_ANON_KEY=${REACT_APP_SUPABASE_ANON_KEY}
ENV REACT_APP_BACKEND_URL=${REACT_APP_BACKEND_URL}
ENV PUBLIC_URL=${PUBLIC_URL}
# Copy source and build the React app
COPY . . 
RUN npm run build --verbose || (echo "⚠️ React build failed!" && exit 1)
# (Optional) Debug: list build folder contents
RUN ls -lah build/

# Stage 2: Build Django Backend
FROM python:3.11-slim AS backend
WORKDIR /final_project
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
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
# Copy the Django project
COPY . /final_project
ENV PYTHONPATH=/final_project
# Collect Django static files (adjust as needed for your project)
RUN python manage.py collectstatic --noinput

# Stage 3: Final Image with Both Services
FROM python:3.11-slim
WORKDIR /final_project
# Install system packages including Nginx
RUN apt-get update && apt-get install -y nginx && apt-get clean

# Copy the React build output to Nginx’s folder (adjust paths as needed)
COPY --from=frontend /frontend/build /usr/share/nginx/html/frontend-static

# Copy your custom Nginx configuration file
# (Ensure your nginx.conf handles both proxying to Django and serving React)
COPY nginx.conf /etc/nginx/nginx.conf

# Expose ports (80 for Nginx, 8000 for Django internally if needed)
EXPOSE 80 8000

# Copy a startup script that runs Gunicorn and then Nginx
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Use the startup script as the container command
CMD ["/start.sh"]