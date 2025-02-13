from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import EventViewSet, user_info, index

# Create a router to automatically handle API endpoints
router = DefaultRouter()
router.register(r'events', EventViewSet, basename='event')

# Define URL patterns
urlpatterns = [
    path('', index, name='scheduler_home'),  # Maps /scheduler/ to the index view
    path('api/user-info/', user_info, name="user_info"),  # ✅ New API to check authentication
]