from django.shortcuts import render
from django.conf import settings
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .serializers import EventSerializer
from .models import Event
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
import json
import os


def index(request):
    """Load React's asset manifest to get correct static file paths dynamically."""
    manifest_path = os.path.join('/usr/share/nginx/html/frontend-static', 'asset-manifest.json')

    try:
        with open(manifest_path, 'r') as f:
            manifest = json.load(f)

        # Get the paths for main.css and main.js from the manifest
        css_file = manifest["files"].get("main.css", "/static/frontend/static/css/main.css")
        js_file = manifest["files"].get("main.js", "/static/frontend/static/js/main.js")

    except FileNotFoundError:
        css_file = "/static/frontend/static/css/main.css"
        js_file = "/static/frontend/static/js/main.js"
        print("⚠️ WARNING: asset-manifest.json not found. Using fallback paths!")

    # Pass the context to base template
    return render(request, 'scheduler/base_scheduler.html', {
        "css_file": css_file,
        "js_file": js_file,
    })

class EventViewSet(viewsets.ModelViewSet):
    """
    API endpoint for viewing, creating, updating, and deleting events.
    """
    queryset = Event.objects.all().order_by('start_time')
    serializer_class = EventSerializer
    permission_classes = [IsAuthenticated]  # Require authentication
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)  # Save event to use

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def user_info(request):
    return Response({"message": "You are authenticated!", "user": request.user.username})