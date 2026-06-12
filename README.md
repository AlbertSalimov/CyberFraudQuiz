# My Django Project

## Как запустить локально
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver

## Структура веток
- `main` — продакшен-версия
- `develop` — текущая разработка
- `feature/*` — новые фичи
