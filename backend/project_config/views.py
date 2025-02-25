import os
import json
from django.shortcuts import render
from django.conf import settings


def home(request):
    #Context Variables are passed to the template by Django's context processor within the settings.py file under TEMPLATES
    return render(request, 'core/home.html')
