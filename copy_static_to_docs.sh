#!/bin/bash
set -e  # Exit immediately if a command fails

# Define source and destination directories
STATICFILES_DIR="/final_project/staticfiles"
DOCS_DIR="/final_project/docs"

echo "Source directory: $STATICFILES_DIR"
echo "Destination directory: $DOCS_DIR"

# Ensure source directory exists
if [ ! -d "$STATICFILES_DIR" ]; then
    echo "Error: Source directory $STATICFILES_DIR does not exist!"
    exit 1
fi

# Ensure destination directory exists
if [ ! -d "$DOCS_DIR" ]; then
    echo "Destination directory does not exist. Creating $DOCS_DIR..."
    mkdir -p "$DOCS_DIR"
fi

# Copy static files from staticfiles to docs, excluding the 'static' subdirectory
echo "Copying files from $STATICFILES_DIR to $DOCS_DIR..."
rsync -av --exclude='static' "$STATICFILES_DIR/" "$DOCS_DIR/"

echo "Files copied successfully! Contents of $DOCS_DIR:"
ls -la "$DOCS_DIR"