from django.shortcuts import render
from django.conf import settings
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .serializers import EventSerializer
from .models import Event
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response


def index(request):
    manifest = settings.REACT_MANIFEST.copy()

    # ✅ Extract paths correctly from "files" key
    files = manifest.get("files", {})
    
    # ✅ Remove extra `/static/` prefix if present
    manifest["files"]["main_js"] = files.get("main.js", "").replace("/static/frontend/static/", "/static/frontend/")
    manifest["files"]["main_css"] = files.get("main.css", "").replace("/static/frontend/static/", "/static/frontend/")

    return render(request, 'scheduler/scheduler_index.html', {"react_manifest": manifest})


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