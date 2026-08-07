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

Перейти в папку проекта и переключиться на ветку develop:

```
cd CyberFraudQuiz/
git checkout develop
```

Создать виртуальное окружение python:

```
python3 -m venv .venv
```

Для настройки базы данных зайти в консоль PostgreSQL от стандартного пользователя postgres:

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

Создать файл .env с переменными окружения:

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

Git будет установлен вместе с docker. Клонировать репозиторий:

```
git clone https://github.com/AlbertSalimov/CyberFraudQuiz.git
```

Перейти в папку проекта:

```
cd CyberFraudQuiz/
```

Создать файл .env с переменными окружения:

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

Запустить контейнеры через docker compose с ключом --build (для сборки контейнера с приложением в первый раз):

```
sudo docker compose up --build
```

Последующие запуски контейнеров на этом же сервере можно осуществлять командой:

```
sudo docker compose up -d
```

Для доступа к сайту перейти по ссылке http://prod_server_ip:8080

Остановка контейнеров:

```
sudo docker compose down
```