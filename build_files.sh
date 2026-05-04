#!/bin/bash
# Install dependencies (--break-system-packages needed for Vercel's uv-managed Python)
pip install --break-system-packages -r requirements.txt

# Create the staticfiles directory
mkdir -p staticfiles

# Run migrations (creates tables in the ephemeral SQLite on Vercel)
python manage.py migrate --noinput

# Seed admin user (idempotent — skips if already exists)
python manage.py shell -c "
from users.models import User
if not User.objects.filter(username='admin').exists():
    u = User.objects.create_superuser(username='admin', email='admin@foodsaver.in', password='Admin@123')
    u.role = 'admin'
    u.save()
    print('Admin user seeded.')
else:
    print('Admin user already exists.')
"

# Collect static files
python manage.py collectstatic --noinput
