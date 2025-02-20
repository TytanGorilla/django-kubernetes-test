import os
import json
from django.shortcuts import render
from django.conf import settings

import requests

def get_asset_paths():
    """Load React's asset manifest to get correct static file paths dynamically."""
    try:
        # URL of the asset-manifest.json served by Nginx
        manifest_url = 'http://nginx-service/static/frontend/asset-manifest.json'
        response = requests.get(manifest_url)
        
        if response.status_code != 200:
            raise FileNotFoundError("Could not fetch asset-manifest.json")

        manifest = response.json()

        # Get the paths for main.css and main.js from the manifest
        css_file = manifest.get("files", {}).get("main.css", "/static/frontend/static/css/main.css")
        js_file = manifest.get("files", {}).get("main.js", "/static/frontend/static/js/main.js")
        return js_file, css_file

    except Exception as e:
        # Handle errors if the file is missing or there are issues
        print(f"Error loading asset manifest: {e}")
        return "/static/frontend/static/js/main.js", "/static/frontend/static/css/main.css"


def home(request):
    # Get the JS and CSS file paths from the asset manifest
    js_file, css_file = get_asset_paths()

    # Pass them as context to the home template
    return render(request, 'core/home.html', {
        'js_file': js_file,
        'css_file': css_file,
    })
