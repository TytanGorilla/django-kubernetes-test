from django.shortcuts import render

def index(request):
    return render(request, 'scheduler/index.html') # Points to apps/scheduler/templates/scheduler/index.html
