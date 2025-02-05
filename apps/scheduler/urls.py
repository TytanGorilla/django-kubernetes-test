from django.urls import path, include
from . import views
from rest_framework.routers import DefaultRouter
from .views import EventViewSet, CalendarViewSet

router = DefaultRouter()
router.register(r'events', EventViewSet)
router.register(r'calendars', CalendarViewSet)

urlpatterns = [
    path('', views.index, name='scheduler_home'),  # Maps /scheduler app/ to the index view
    path('api/', include(router.urls)),
]