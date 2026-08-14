#!/bin/sh
set -e

python manage.py migrate --noinput
python manage.py loaddata questions.json

exec gunicorn CyberFraudQuiz.wsgi:application --bind 0.0.0.0:8000 --workers 3
