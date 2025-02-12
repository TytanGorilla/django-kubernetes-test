# ------------------ FRONTEND (React) ------------------
    FROM node:18 AS frontend
    WORKDIR /frontend
    
    # Copy package files and install dependencies
    COPY package.json package-lock.json ./
    RUN npm install --silent
    
    # ✅ Load environment variables from build args
    ARG REACT_APP_SUPABASE_URL
    ARG REACT_APP_SUPABASE_ANON_KEY
    ENV REACT_APP_SUPABASE_URL=$REACT_APP_SUPABASE_URL
    ENV REACT_APP_SUPABASE_ANON_KEY=$REACT_APP_SUPABASE_ANON_KEY
    
    # Copy source files and build React
    COPY . ./
    RUN npm run build --verbose || (echo "⚠️ React build failed!" && exit 1)
    
    # ✅ Debug: Check if build was successful
    RUN ls -lah build/
    
    # Serve built frontend using Nginx
    FROM nginx:alpine AS final
    WORKDIR /usr/share/nginx/html
    
    # ✅ Copy React's built files to Nginx
    COPY --from=frontend /frontend/build/ ./
    
    # Expose the port
    EXPOSE 80
    CMD ["nginx", "-g", "daemon off;"]    