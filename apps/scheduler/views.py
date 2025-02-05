from django.shortcuts import render
from django.conf import settings
from rest_framework import viewsets
from .serializers import EventSerializer, CalendarSerializer
from .models import Event, Calendar

def index(request):
    manifest = settings.REACT_MANIFEST.copy()
    files = manifest.get("files", {})
    # Create new keys without the leading "/static/"
    manifest["files"]["main_js"] = files.get("main.js", "").lstrip("/static/")
    manifest["files"]["main_css"] = files.get("main.css", "").lstrip("/static/")
    return render(request, 'scheduler/scheduler_index.html', {"react_manifest": manifest}) # Points to apps/scheduler/templates/scheduler/index.html

class EventViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows events to be viewed or edited.
    """
    queryset = Event.objects.all().order_by('start_time')
    serializer_class = EventSerializer

class CalendarViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows calendars to be viewed or edited.
    """
    queryset = Calendar.objects.all().order_by('created_at')
    serializer_class = CalendarSerializer