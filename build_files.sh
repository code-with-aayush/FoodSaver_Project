#!/bin/bash
# Install dependencies
pip install -r requirements.txt

# Create the staticfiles directory
mkdir -p staticfiles

# Collect static files
python manage.py collectstatic --noinput
