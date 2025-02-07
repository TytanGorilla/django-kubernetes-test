from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import EventViewSet, CalendarViewSet, user_info, index

# Create a router to automatically handle API endpoints
router = DefaultRouter()
router.register(r'events', EventViewSet, basename='event')
router.register(r'calendars', CalendarViewSet, basename='calendar')

# Define URL patterns
urlpatterns = [
    path('', index, name='scheduler_home'),  # Maps /scheduler/ to the index view
    path('api/', include(router.urls)),  # Registers all API routes
    path('api/user-info/', user_info, name="user_info"),  # ✅ New API to check authentication
]