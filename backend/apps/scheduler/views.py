from django.shortcuts import render
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .serializers import EventSerializer
from .models import Event
from rest_framework.response import Response
import json
import os
import requests
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import AuthenticationForm, LogoutView



@login_required 
def index(request):
    return render(request, 'scheduler/scheduler_index.html')

def login(request):
    if request.method == 'POST':
        form = AuthenticationForm(data=request.POST)
        if form.is_valid():
            user = form.get_user()
            login(request, user)
            return redirect('scheduler_index')
    else:
        form = AuthenticationForm()
    return render(request, 'scheduler_login.html', {'form': form})

class CustomLogoutView(LogoutView):
    def dispatch(self, request, *args, **kwargs):
        # Perform any additional actions here upon logout. For example:
        # Clear session data (optional)
        request.session.flush()

        # Call the parent class's dispatch method to handle the actual logout.
        return super().dispatch(request, *args, **kwargs)

class EventViewSet(viewsets.ModelViewSet):
    """
    API endpoint for viewing, creating, updating, and deleting events.
    """
    queryset = Event.objects.all().order_by('start_time')
    serializer_class = EventSerializer
    permission_classes = [IsAuthenticated]  # Require authentication
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)  # Save event to use

