import os
import json
from django.shortcuts import render
from django.conf import settings

def get_asset_paths():
    """Load React's asset manifest to get correct static file paths dynamically."""
    try:
        # Path to the asset-manifest.json in the Nginx static serving directory
        manifest_path = '/usr/share/nginx/html/frontend-static/asset-manifest.json'

        # Try opening and reading the manifest file
        with open(manifest_path, 'r') as f:
            manifest = json.load(f)

        # Get the paths for main.css and main.js from the manifest
        css_file = manifest.get("files", {}).get("main.css", "/static/frontend/static/css/main.css")
        js_file = manifest.get("files", {}).get("main.js", "/static/frontend/static/js/main.js")
        return js_file, css_file

    except FileNotFoundError:
        # Fallback paths if the manifest is not found
        print("⚠️ WARNING: asset-manifest.json not found. Using fallback paths!")
        return "/static/frontend/static/js/main.js", "/static/frontend/static/css/main.css"

def home(request):
    # Get the JS and CSS file paths from the asset manifest
    js_file, css_file = get_asset_paths()

    # Pass them as context to the home template
    return render(request, 'core/home.html', {
        'js_file': js_file,
        'css_file': css_file,
    })
