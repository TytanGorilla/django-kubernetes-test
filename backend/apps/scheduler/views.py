from django.shortcuts import render
from django.conf import settings
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .serializers import EventSerializer
from .models import Event
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response


import json
from django.shortcuts import render
import os

import json
import os
from django.shortcuts import render

def index(request):
    # Load the React build asset manifest from a Django-accessible location
    manifest_path = os.path.join('/final_project/static/manifest', 'asset-manifest.json')

    # Read the manifest
    try:
        with open(manifest_path, 'r') as f:
            manifest = json.load(f)

        # Get the paths for main.js and main.css from the manifest
        css_file = manifest['files'].get('main.css')
        js_file = manifest['files'].get('main.js')

    except FileNotFoundError:
        # Handle error if the manifest file is not found
        css_file = js_file = None
        print("Asset manifest not found. Ensure the React build is in place.")

    # Pass the paths to the template
    return render(request, 'scheduler/scheduler_index.html', {
        'css_file': css_file,
        'js_file': js_file,
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