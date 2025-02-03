from django.shortcuts import render
from django.conf import settings

def index(request):
    manifest = settings.REACT_MANIFEST.copy()
    files = manifest.get("files", {})
    # Create new keys that don't contain dots.
    manifest["files"]["main_js"] = files.get("main.js")
    manifest["files"]["main_css"] = files.get("main.css")
    return render(request, 'scheduler/scheduler_index.html', {"react_manifest": manifest}) # Points to apps/scheduler/templates/scheduler/index.html
