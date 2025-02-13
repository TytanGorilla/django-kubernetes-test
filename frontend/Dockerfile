# ------------------ FRONTEND (React) ------------------
    FROM node:18 AS frontend
    WORKDIR /frontend
    
    # Copy package files and install dependencies
    COPY package.json package-lock.json ./
    RUN npm install --silent
    
    # ✅ Load environment variables from build args
    ARG REACT_APP_BUILD_VERSION
    ARG REACT_APP_SUPABASE_URL
    ARG REACT_APP_SUPABASE_ANON_KEY
    ARG REACT_APP_BACKEND_URL
    ARG PUBLIC_URL
    
    # ✅ Set them as ENV so React can use them
    ENV REACT_APP_BUILD_VERSION=$REACT_APP_BUILD_VERSION
    ENV REACT_APP_SUPABASE_URL=$REACT_APP_SUPABASE_URL
    ENV REACT_APP_SUPABASE_ANON_KEY=$REACT_APP_SUPABASE_ANON_KEY
    ENV REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL
    ENV PUBLIC_URL=$PUBLIC_URL
    
    # ✅ Copy source files and build React
    COPY . ./
    RUN npm run build --verbose || (echo "⚠️ React build failed!" && exit 1)
    
    # ✅ Debug: Check that the build folder was created
    RUN ls -lah build/
    
    # ------------------ Serve React via Nginx ------------------
    FROM nginx:alpine AS final
    WORKDIR /usr/share/nginx/html
    
    # ✅ Copy React’s built files into Nginx’s dedicated frontend static folder
    COPY --from=frontend /frontend/build/ /usr/share/nginx/html/frontend-static/
    
    # ✅ Expose the port Nginx will serve on
    EXPOSE 80
    
    # ✅ Start Nginx
    CMD ["nginx", "-g", "daemon off;"]    