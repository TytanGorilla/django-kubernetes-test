from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),  # Maps /app_1/ to the index view
]
