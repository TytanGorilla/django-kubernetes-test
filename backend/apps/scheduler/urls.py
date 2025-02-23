from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import EventViewSet, index

# Create a router to automatically handle API endpoints
router = DefaultRouter()
router.register(r'events', EventViewSet, basename='event')

# Define URL patterns
urlpatterns = [
    path('', index, name='scheduler_home'),  # Maps /scheduler/ to the index view
    path('login/', views.LoginView.as_view(), name='scheduler_login'),
    path('logout/', CustomLogoutView.as_view(), name='scheduler_logout')
]