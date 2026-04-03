#!/bin/bash
# Install dependencies (--break-system-packages needed for Vercel's uv-managed Python)
pip install --break-system-packages -r requirements.txt

# Create the staticfiles directory
mkdir -p staticfiles

# Collect static files
python manage.py collectstatic --noinput
