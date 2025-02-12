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
    
    # ✅ Copy the entire project
    COPY . /final_project
    
    # ✅ Ensure Python path
    ENV PYTHONPATH=/final_project
    
    # ✅ Install Kubernetes tools (if needed)
    RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
        chmod +x kubectl && \
        mv kubectl /usr/local/bin/
    
    # ✅ Make entrypoint executable
    COPY entrypoint.sh /entrypoint.sh
    RUN chmod +x /entrypoint.sh
    
    # Expose Django port
    EXPOSE 8000
    
    # ✅ Run entrypoint script to collect static files and start server
    CMD ["bash", "/entrypoint.sh"]    