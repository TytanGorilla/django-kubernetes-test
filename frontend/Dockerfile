# ------------------ FRONTEND (React) ------------------
    FROM node:18 AS frontend
    WORKDIR /frontend
    
    # Copy package files and install dependencies
    COPY package.json package-lock.json ./
    RUN npm install --silent
    
    # Copy all frontend source files and build the React app
    COPY . ./
    
    # ✅ Load environment variables from build args
    ARG REACT_APP_SUPABASE_URL
    ARG REACT_APP_SUPABASE_ANON_KEY
    ENV REACT_APP_SUPABASE_URL=$REACT_APP_SUPABASE_URL
    ENV REACT_APP_SUPABASE_ANON_KEY=$REACT_APP_SUPABASE_ANON_KEY
    
    # ✅ Force build React
    RUN npm run build --verbose || (echo "⚠️ React build failed!" && exit 1)
    
    # ✅ Debug: Ensure cache-busting version is set
    RUN cat build/index.html | grep main.js || echo "⚠️ No cache-busting found!"
    
    # ✅ Serve built frontend using Nginx
    FROM nginx:alpine AS final
    WORKDIR /usr/share/nginx/html
    
    # Copy React's built files into Nginx's web root
    COPY --from=frontend /frontend/build/ ./
    
    # Expose the port the app runs on
    EXPOSE 80
    
    # ✅ Start Nginx
    CMD ["nginx", "-g", "daemon off;"]    