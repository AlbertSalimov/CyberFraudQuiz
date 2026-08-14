# Сайт квеста по кибермошенничеству

## Структура веток

- `main` — продакшен-версия
- `develop` — текущая разработка

## Запуск вручную для разработки (на примере Debian 13)

Установить требуемые пакеты в системе:

```
sudo apt update
sudo apt install git python3 python3.13-venv postgresql
```

Клонировать репозиторий:

```
git clone https://github.com/AlbertSalimov/CyberFraudQuiz.git
```

Перейти в папку проекта и переключиться на ветку `develop`:

```
cd CyberFraudQuiz/
git checkout develop
```

Создать виртуальное окружение python:

```
python3 -m venv .venv
```

Для настройки базы данных зайти в консоль PostgreSQL от стандартного пользователя `postgres`:

```
sudo -u postgres psql
```

Создать пользователя, от которого будет подключаться наше приложение к базе данных:

```
CREATE USER your_user WITH PASSWORD 'your_password';
```

Создать базу данных, с которой будет работать наше приложение:

```
CREATE DATABASE database_name OWNER your_user;
```

Дать права нашему пользователю:

```
GRANT ALL ON SCHEMA public TO your_user;
```

Выйти из консоли PostgreSQL:

```
\q
```

Создать файл `.env` с переменными окружения:

```
DB_NAME=database_name
DB_USER=your_user
DB_PASSWORD=your_password
DB_HOST=database_server_ip
DB_PORT=5432
SECRET_KEY=your_secret_key
ALLOWED_HOSTS=*
```

Выполнить миграции:

```
python3 manage.py migrate
```

Загрузить вопросы для квеста в базу данных:

```
python3 manage.py loaddata questions.json
```

Запустить приложение:

```
python3 manage.py runserver
```

Для доступа к сайту перейти по ссылке http://127.0.0.1:8000

## Запуск в docker-контейнере на продакшене (на примере Debian 13)

Установить docker:

```
sudo curl -fsSL https://get.docker.com | sh
```

Создать папку для проекта, например `/opt/CyberFraudQuiz`:

```
sudo mkdir /opt/CyberFraudQuiz
```

Перейти в папку проекта:

```
cd /opt/CyberFraudQuiz
```

Создать файл `docker-compose.yml`:

```
services:
  db:
    image: postgres:17-alpine
    container_name: django_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=${DB_NAME}
    ports:
      - "5432:5432"
    healthcheck:
      test: [ "CMD-SHELL", "pg_isready -U ${DB_USER}" ]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  web:
    image: ghcr.io/albertsalimov/cyber_fraud_quiz:latest
    container_name: django_app
    env_file:
      - .env
    volumes:
      - static_volume:/opt/CyberFraudQuiz/staticfiles
    expose:
      - "8000"
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

  nginx:
    image: nginx:1.26-alpine
    container_name: django_nginx
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf
      - static_volume:/opt/CyberFraudQuiz/staticfiles
    ports:
      - "80:80"
    depends_on:
      - web
    restart: unless-stopped

volumes:
  postgres_data:
  static_volume:
```

Создать файл `.env` с переменными окружения:

```
DB_NAME=database_name
DB_USER=your_user
DB_PASSWORD=your_password
DB_HOST=db
DB_PORT=5432
SECRET_KEY=your_secret_key
ALLOWED_HOSTS=prod_server_ip
CSRF_TRUSTED_ORIGINS=http://prod_server_ip:8080
```

Создать файл `nginx.conf` в подпапке `nginx`:

```
upstream django_app {
    server web:8000;
}

server {
    listen 80;

    access_log /var/log/nginx/CyberFraudQuiz_access.log;
    error_log /var/log/nginx/CyberFraudQuiz_error.log;

    location /static/ {
        alias /opt/CyberFraudQuiz/staticfiles/;
        expires 30d;
    }

    location / {
        proxy_pass http://django_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Запустить контейнеры через docker compose:

```
sudo docker compose up -d
```

Для доступа к сайту перейти по ссылке http://prod_server_ip