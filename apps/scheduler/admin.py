from django.contrib import admin
from .models import Calendar, Event

# Customizing the Admin Panel for Event Model
class EventAdmin(admin.ModelAdmin):
    list_display = ('title', 'calendar', 'start_time', 'end_time', 'all_day')  # Columns in admin list view
    list_filter = ('calendar', 'start_time')  # Filter options in the sidebar
    search_fields = ('title', 'description')  # Search bar for events

# Register models with the admin site
admin.site.register(Calendar)
admin.site.register(Event, EventAdmin)  # Use the custom admin class