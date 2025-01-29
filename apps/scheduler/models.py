from django.contrib.auth.models import User  # ✅ Import Django's User model
from django.db import models

class Calendar(models.Model):
    name = models.CharField(max_length=100)
    user = models.ForeignKey(User, on_delete=models.CASCADE)  # Link to User
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} - {self.user.username}"  # ✅ Improved readability

class Event(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    calendar = models.ForeignKey(Calendar, on_delete=models.CASCADE)  # Linked to Calendar
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    all_day = models.BooleanField(default=False)  # Is it an all-day event?
    location = models.CharField(max_length=255, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)  # ✅ Track event creation

    def __str__(self):
        return f"{self.title} ({self.start_time.strftime('%Y-%m-%d %H:%M')})"

class Task(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    due_date = models.DateTimeField(blank=True, null=True)
    completed = models.BooleanField(default=False)
    calendar = models.ForeignKey(Calendar, on_delete=models.CASCADE)  # Tasks are linked to a calendar
    created_at = models.DateTimeField(auto_now_add=True)  # ✅ Track task creation

    def __str__(self):
        status = "✓" if self.completed else "✗"
        return f"[{status}] {self.name} - Due: {self.due_date.strftime('%Y-%m-%d %H:%M') if self.due_date else 'No Due Date'}"
