import requests

def asset_paths(request):
    """Load React's asset manifest via Nginx."""
    try:
        # ✅ Use the Nginx-exposed URL
        manifest_url = "http://nginx-service/static/frontend/asset-manifest.json"
        response = requests.get(manifest_url)

        if response.status_code != 200:
            raise FileNotFoundError("Could not fetch asset-manifest.json")

        manifest = response.json()

        # ✅ Extract dynamic paths
        css_file = manifest.get("files", {}).get("main.css", "/static/frontend/static/css/main.css")
        js_file = manifest.get("files", {}).get("main.js", "/static/frontend/static/js/main.js")

    except Exception as e:
        print(f"⚠️ WARNING: Error loading asset manifest: {e}")
        css_file = "/static/frontend/static/css/main.css"
        js_file = "/static/frontend/static/js/main.js"

    # Return a dictionary of context variables that will be available to all templates rendered by views
    return {
        'css_file': css_file,
        'js_file': js_file
    }
