# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory
WORKDIR /usr/src/app

# Copy the requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
# CMD ["tail", "-f", "/dev/null"]
