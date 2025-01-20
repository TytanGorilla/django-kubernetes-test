"""
Django settings for myproject project.

Generated by 'django-admin startproject' using Django 3.2.25.

For more information on this file, see
https://docs.djangoproject.com/en/3.2/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/3.2/ref/settings/
"""

import os
from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# ------------------------------------------------------------------------------------
# SECURITY
# ------------------------------------------------------------------------------------
# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.getenv("DJANGO_SECRET_KEY", "fallback_secret")

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = os.getenv("DJANGO_DEBUG", "False").lower() == "true"

# By default, allow local hosts or any fallback.
ALLOWED_HOSTS = os.getenv("DJANGO_ALLOWED_HOSTS", "localhost,127.0.0.1").split(",")
# ------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------
# Application definition
# ------------------------------------------------------------------------------------
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'corsheaders',
    # Add your custom apps here
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.common.CommonMiddleware",  # Must come after CorsMiddleware
]

ROOT_URLCONF = 'myproject.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],  # Add any template directories if needed
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'myproject.wsgi.application'


# ------------------------------------------------------------------------------------
# Database Configuration
# ------------------------------------------------------------------------------------
# You can either:
# 1) Use individual environment variables (POSTGRES_DB, POSTGRES_USER, etc.), or
# 2) Use a full DATABASE_URL environment variable (e.g., "postgresql://user:pass@db:5432/dbname").

# EXAMPLE 1: Using individual environment variables
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv("POSTGRES_DB", "postgres"),
        'USER': os.getenv("POSTGRES_USER", "postgres"),
        'PASSWORD': os.getenv("POSTGRES_PASSWORD", ""),
        'HOST': os.getenv("POSTGRES_HOST", "db"),
        'PORT': os.getenv("POSTGRES_PORT", "5432"),
    }
}

# EXAMPLE 2: Using DATABASE_URL (comment out EXAMPLE 1 if you choose this approach)
# import dj_database_url
# DATABASES = {
#     'default': dj_database_url.config(default="postgresql://postgres:@db:5432/postgres")
# }

# ------------------------------------------------------------------------------------
# Password validation
# ------------------------------------------------------------------------------------
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# ------------------------------------------------------------------------------------
# Internationalization
# ------------------------------------------------------------------------------------
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = True
USE_TZ = True

# ------------------------------------------------------------------------------------
# Static files (CSS, JavaScript, Images)
# ------------------------------------------------------------------------------------
STATIC_URL = '/static/'

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Aiming to allow apps access
CORS_ALLOW_ALL_ORIGINS = True

CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",  # Replace with your frontend's URL
    "http://192.168.49.2:30007",
]

CORS_ALLOW_CREDENTIALS = True

CORS_ALLOW_METHODS = [
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE",
    "OPTIONS",
]

CORS_ALLOW_HEADERS = [
    "content-type",
    "authorization",
    "x-custom-header",
]

SECURE_SSL_REDIRECT = False  # Disable HTTPS redirection for development
