from django.shortcuts import render
from django.conf import settings

def index(request):
    return render(request, 'scheduler/scheduler_index.html', {"react_manifest": settings.REACT_MANIFEST}) # Points to apps/scheduler/templates/scheduler/index.html
