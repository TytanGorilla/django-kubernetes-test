from django.contrib import admin
from .models import Event

# Customizing the Admin Panel for Event Model
class EventAdmin(admin.ModelAdmin):
    list_display = ('title', 'start_time', 'end_time')  # ❌ Removed 'calendar'
    list_filter = ('start_time',)  # ❌ Removed 'calendar'
    search_fields = ('title', 'description')

# Register models with the admin site
admin.site.register(Event, EventAdmin)