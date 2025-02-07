from django.shortcuts import render
from django.conf import settings
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .serializers import EventSerializer, CalendarSerializer
from .models import Event, Calendar
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response

def index(request):
    manifest = settings.REACT_MANIFEST.copy()
    
    # Adjust paths inside the manifest to match STATIC_URL
    if "files" in manifest:
        for key, value in manifest["files"].items():
            if value.startswith("/static/"):
                manifest["files"][key] = value.lstrip("/static/")  # Remove extra prefix
    
    return render(request, 'scheduler/scheduler_index.html', {"react_manifest": manifest})

class EventViewSet(viewsets.ModelViewSet):
    """
    API endpoint for viewing, creating, updating, and deleting events.
    """
    queryset = Event.objects.all().order_by('start_time')
    serializer_class = EventSerializer
    permission_classes = [IsAuthenticated]  # Require authentication 

class CalendarViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows calendars to be viewed or edited.
    """
    queryset = Calendar.objects.all().order_by('created_at')
    serializer_class = CalendarSerializer

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def user_info(request):
    return Response({"message": "You are authenticated!", "user": request.user.username})