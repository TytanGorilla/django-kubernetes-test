from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import EventViewSet, CalendarViewSet, user_info

# ✅ Create API Router (DRF auto-manages API paths)
router = DefaultRouter()
router.register(r'events', EventViewSet, basename='event')
router.register(r'calendars', CalendarViewSet, basename='calendar')

urlpatterns = [
    path('', include(router.urls)),  # ✅ Now `/api/events/` and `/api/calendars/` work
    path('user-info/', user_info, name="user_info"),  # ✅ `/api/user-info/`
]