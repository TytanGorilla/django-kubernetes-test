from django.urls import path, include
from .views import EventViewSet, CalendarViewSet, user_info
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'events', EventViewSet)
router.register(r'calendars', CalendarViewSet)

urlpatterns = [
    path('', views.index, name='scheduler_home'),  # Maps /scheduler app/ to the index view
    path('api/', include(router.urls)),
    path('api/user-info/', user_info, name="user_info"),  # ✅ New API to check authentication
]