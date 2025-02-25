from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import EventViewSet, index, CustomLogoutView
from django.urls import reverse_lazy
from django.contrib.auth import views as auth_views
from django.urls import path


# Create a router to automatically handle API endpoints
router = DefaultRouter()
router.register(r'events', EventViewSet, basename='event')

# Define URL patterns
urlpatterns = [
    path('', index, name='scheduler_home'),  # Maps /scheduler/ to the index view
    path('login/', auth_views.LoginView.as_view(template_name='scheduler/scheduler_login.html'), name='scheduler_login'),
    path('logout/', CustomLogoutView.as_view(), name='scheduler_logout')
]