from django.shortcuts import render
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .serializers import EventSerializer
from .models import Event
from django.contrib.auth.views import LogoutView
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import UserCreationForm
from django.urls import reverse_lazy
from django.views.generic import CreateView

@login_required
def index(request):
    return render(request, 'scheduler/base_scheduler.html')

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

class RegisterView(CreateView):
    form_class = UserCreationForm
    template_name = 'scheduler/register.html'
    success_url = reverse_lazy('scheduler_login')
