import json
import os
from django.conf import settings
from django.shortcuts import render

def get_asset_paths(manifest_path):
    """Load the asset manifest file."""
    try:
        with open(manifest_path, 'r') as f:
            manifest = json.load(f)

        # Get the paths for main.js and main.css from the manifest
        css_file = manifest["files"].get("main.css", "/static/frontend/static/css/main.css")
        js_file = manifest["files"].get("main.js", "/static/frontend/static/js/main.js")

    except FileNotFoundError:
        css_file = "/static/frontend/static/css/main.css"
        js_file = "/static/frontend/static/js/main.js"
        print("⚠️ WARNING: asset-manifest.json not found. Using fallback paths!")
    
    return js_file, css_file

def home(request):
    """Get the JS and CSS file paths from the asset manifest."""
    # Define the path to the asset-manifest.json for the core app
    manifest_path = '/usr/share/nginx/html/frontend-static/asset-manifest.json'

    # Get the JS and CSS file paths using the function
    js_file, css_file = get_asset_paths(manifest_path)

    # Pass them as context to the home template
    return render(request, 'core/home.html', {
        'js_file': js_file,
        'css_file': css_file,
    })
