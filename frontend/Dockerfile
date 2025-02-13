# ------------------ FRONTEND (React) ------------------
    FROM node:18 AS frontend
    WORKDIR /frontend
    
    # Copy package files and install dependencies
    COPY package.json package-lock.json ./
    RUN npm install --silent
    
    # Load environment variables from build args
    ARG REACT_APP_SUPABASE_URL
    ARG REACT_APP_SUPABASE_ANON_KEY
    ENV REACT_APP_SUPABASE_URL=$REACT_APP_SUPABASE_URL
    ENV REACT_APP_SUPABASE_ANON_KEY=$REACT_APP_SUPABASE_ANON_KEY
    
    # Copy source files and build React
    COPY . ./
    RUN npm run build --verbose || (echo "⚠️ React build failed!" && exit 1)
    
    # Debug: Check that the build folder was created
    RUN ls -lah build/
    
    # ------------------ Serve React via Nginx ------------------
    FROM nginx:alpine AS final
    WORKDIR /usr/share/nginx/html
        
    # Copy React’s built files into Nginx’s dedicated frontend static folder
    COPY --from=frontend /frontend/build/ /usr/share/nginx/html/frontend-static/
    
    # Expose the port Nginx will serve on
    EXPOSE 80
    CMD ["nginx", "-g", "daemon off;"]    