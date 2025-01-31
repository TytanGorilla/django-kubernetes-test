from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='scheduler_home'),  # Maps /scheduler app/ to the index view
]
