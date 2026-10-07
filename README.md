# Сайт квеста по кибермошенничеству

Веб-приложение для проведения викторин по кибербезопасности.

## Оглавление

- [Технологии](#технологии)
- [Требования](#требования)
- [Запуск](#запуск)
- [Конфигурация](#конфигурация)
- [CI/CD](#cicd)
- [Мониторинг](#мониторинг)
- [Инфраструктура как код](#инфраструктура-как-код)
- [Ansible](#ansible)
- [Структура проекта](#структура-проекта)
- [Автор](#автор)
- [Демо](#демо)

---

## Технологии

| Компонент            | Технология                           |
| -------------------- | ------------------------------------ |
| **Backend**          | Django + Gunicorn                    |
| **Database**         | PostgreSQL                           |
| **Web Server**       | Nginx                                |
| **Containerization** | Docker + Docker Compose              |
| **CI/CD**            | GitHub Actions                       |
| **Monitoring**       | Prometheus + Grafana + Node Exporter |
| **Registry**         | GitHub Container Registry (GHCR)     |

---

## Требования

- Docker v29+
- Docker Compose v5+

---

## Запуск

### На продакшене (на примере Debian 13)

#### 1. Установка Docker

```bash
sudo curl -fsSL https://get.docker.com | sh
```

#### 2. Создание папки для проекта

```bash
sudo mkdir /opt/CyberFraudQuiz
```

#### 3. Запуск deploy-скрипта

```bash
cd /opt/CyberFraudQuiz
wget -q -O deploy.sh https://raw.githubusercontent.com/AlbertSalimov/CyberFraudQuiz/refs/heads/main/deploy.sh
chmod +x deploy.sh
./deploy.sh
```

Скрипт выполняет следующие действия:

- скачивание необходимых файлов (`docker-compose.yml`; конфиги `nginx`, `prometheus`, `grafana`);
- генерация случайных имени пользователя и пароля для базы данных;
- генерация случайного `secret_key` для Django;
- определение внешнего IP адреса сервера для переменной `ALLOWED_HOSTS`;
- сохранение всех данных в файл с переменными окружения `.env`;
- запуск контейнеров через `docker compose`.

После запуска доступны ссылки:

- **Сайт**: `http://server_ip`
- **Админка**: `http://server_ip/admin`
- **Метрики Django**: `http://server_ip/metrics`

### Запуск вручную для разработки

<details>
<summary>Инструкция на примере Debian 13</summary>

#### 1. Установка требуемых пакетов в системе

```bash
sudo apt update
sudo apt install git python3 python3.13-venv postgresql
```

#### 2. Клонирование репозитория

```bash
git clone https://github.com/AlbertSalimov/CyberFraudQuiz.git
```

#### 3. Переключение на ветку develop

```bash
cd CyberFraudQuiz/
git checkout develop
```

#### 4. Создание виртуального окружения python

```bash
python3 -m venv .venv
```

#### 5. Настройка базы данных

Вход в консоль PostgreSQL от стандартного пользователя `postgres` для настройки базы данных:

```bash
sudo -u postgres psql
```

Создание пользователя, от которого будет подключаться наше приложение к базе данных:

```sql
CREATE USER your_user WITH PASSWORD 'your_password';
```

Создание базы данных, с которой будет работать наше приложение:

```sql
CREATE DATABASE database_name OWNER your_user;
```

Установка прав нашему пользователю:

```sql
GRANT ALL ON SCHEMA public TO your_user;
```

Выход из консоли PostgreSQL:

```sql
\q
```

#### 6. Создание файла `.env` с переменными окружения

```conf
DB_NAME=database_name
DB_USER=your_user
DB_PASSWORD=your_password
DB_HOST=database_server_ip
DB_PORT=5432
SECRET_KEY=your_secret_key
ALLOWED_HOSTS=*
```

#### 7. Выполнение миграций

```bash
python3 manage.py migrate
```

#### 8. Загрузка вопросов для квеста в базу данных

```bash
python3 manage.py loaddata questions.json
```

#### 9. Запуск приложения

```bash
python3 manage.py runserver
```

Сайт будет доступен по ссылке `http://127.0.0.1:8000`

</details>

---

## Конфигурация

<details>
<summary>Переменные окружения (.env)</summary>

| Переменная             | Описание              | Пример                                  |
| ---------------------- | --------------------- | --------------------------------------- |
| `DB_NAME`              | Имя базы данных       | `cyber_fraud_quiz`                      |
| `DB_USER`              | Пользователь БД       | генерируется автоматически              |
| `DB_PASSWORD`          | Пароль БД             | генерируется автоматически              |
| `DB_HOST`              | Хост БД               | `db`                                    |
| `DB_PORT`              | Порт БД               | `5432`                                  |
| `SECRET_KEY`           | Секретный ключ Django | генерируется автоматически              |
| `ALLOWED_HOSTS`        | Разрешенные хосты     | `localhost,web,192.168.1.100`           |
| `CSRF_TRUSTED_ORIGINS` | Доверенные источники  | `http://localhost,http://192.168.1.100` |

</details>
<details>
<summary>Docker Compose сервисы</summary>

| Сервис       | Описание           | Порт   |
| ------------ | ------------------ | ------ |
| `db`         | PostgreSQL         | `5432` |
| `web`        | Django + Gunicorn  | `8000` |
| `nginx`      | Nginx (веб-сервер) | `80`   |
| `prometheus` | Сбор метрик        | `9090` |
| `grafana`    | Визуализация       | `3000` |

</details>

---

## CI/CD

При пуше в ветку `main` автоматически:

1. Собирается Docker-образ;
2. Образ публикуется в GitHub Container Registry (GHCR);
3. Происходит деплой на сервер по SSH.

<details>
<summary>Необходимые секреты GitHub</summary>

| Имя               | Описание                                          |
| ----------------- | ------------------------------------------------- |
| `SSH_HOST`        | IP-адрес сервера                                  |
| `SSH_PORT`        | Порт SSH                                          |
| `SSH_PRIVATE_KEY` | Приватный SSH-ключ                                |
| `SSH_USER`        | Имя пользователя                                  |
| `GITHUB_TOKEN`    | Токен доступа (генерируется автоматически GitHub) |

</details>

---

## Мониторинг

После запуска проекта доступны:

- **Prometheus**: `http://server_ip:9090`
- **Grafana**: `http://server_ip:3000`
- **Node Exporter**: `http://server_ip:9100/metrics`

<details>
<summary>Дашборды Grafana</summary>

| Дашборд              | Описание                    |
| -------------------- | --------------------------- |
| `Django`             | Статистика запросов к сайту |
| `Node Exporter Full` | Состояние сервера           |

</details>

---

## Инфраструктура как код

Инфраструктура проекта описана с помощью **Terraform** и хранится в папке `terraform/`. Это позволяет:

- Создавать всю инфраструктуру одной командой;
- Сохранять историю изменения инфраструктуры в Git;
- Переиспользовать код для разных окружений.

В качестве провайдера для данного проекта был выбран `Yandex Cloud`.

### Структура

```
terraform/
├── modules/
│   ├── compute/              # модуль виртуальной машины
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc/                  # модуль виртуальной сети
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── main.tf                   # основной конфиг Terraform
├── outputs.tf                # выходные значения
├── providers.tf              # настройка провайдера Yandex Cloud
├── terraform.tfvars.example  # шаблон значений для переменных
└── variables.tf              # переменные
```

### Запуск

```bash
cd terraform
terraform init      # инициализация и установка провайдера
terraform plan      # план изменений
terraform apply     # создание инфраструктуры
```

### Получение IP адреса

```bash
terraform output external_ip
```

В результате была создана виртуальная машина в `Yandex Cloud` со следующими параметрами:

- **OS**: `Debian 13`
- **CPU**: `2 cores`
- **RAM**: `2 GB`
- **Disk**: `10 GB`

---

## Ansible

Для настройки сервера и развертывания приложения используется **Ansible**. Плейбук автоматически:

- Устанавливает Docker (если не установлен)
- Создает рабочую директорию
- Скачивает актуальный `deploy.sh`
- Запускает развертывание

### Структура

```
ansible/
├── ansible.cfg         # настройки Ansible
├── inventory/
│   └── hosts.ini       # список серверов
└── playbooks/
    └── deploy.yml      # основной плейбук
```

### Запуск

#### 1. Установка Ansible

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y ansible
```

#### 2. Настройка параметров подключения

Отредактировать `ansible/inventory/hosts.ini`:

```ini
[webservers]
web1 ansible_host=192.168.1.100 ansible_user=debian ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

#### 3. Запуск плейбука

```bash
cd ansible
ansible-playbook playbooks/deploy.yml
```

### Что делает плейбук

| Шаг | Задача                         | Модуль Ansible |
| --- | ------------------------------ | -------------- |
| 1   | Проверка наличия Docker        | `command`      |
| 2   | Установка Docker               | `shell`        |
| 3   | Запуск Docker                  | `service`      |
| 4   | Создание `/opt/CyberFraudQuiz` | `file`         |
| 5   | Скачивание `deploy.sh`         | `get_url`      |
| 6   | Запуск `deploy.sh`             | `command`      |

### Идемпотентность

При повторном запуске плейбук **не вносит изменений**, если система уже в нужном состоянии:

```
PLAY RECAP *****************************************************
web1 : ok=5  changed=0  unreachable=0  failed=0  skipped=3
```

`changed=0` означает, что все уже настроено.

---

## Структура проекта

```
CyberFraudQuiz
├── .github/
│   └── workflows/
│       └── deploy.yml    # CI/CD пайплайн
├── ansible/              # конфиги для Ansible
├── CyberFraudQuiz/       # настройки Django-проекта
├── CyberFraudQuizSite/   # основной код приложения
├── static/               # папка со статическими файлами приложения (css, иконки)
├── terraform/            # конфиги для Terraform
├── .dockerignore         # файлы для исключения из Docker-образа
├── .env.example          # шаблон переменных окружения
├── .gitignore            # игнорируемые файлы
├── Dockerfile            # сборка образа Django-приложения
├── deploy.sh             # развертывание на сервере
├── docker-compose.yml    # оркестрация всех сервисов
├── entrypoint.sh         # скрипт для миграций и загрузки вопросов
├── grafana.ini           # конфигурация Grafana
├── nginx.conf            # конфигурация веб-сервера
├── prometheus.yml        # конфигурация Prometheus
├── questions.json        # список вопросов для загрузки в приложение
└── requirements.txt      # зависимости Python
```

---

## Автор

**Albert Salimov** - System Administrator  
[GitHub](https://github.com/AlbertSalimov) · [Telegram](https://t.me/albert_salimov99) · [Email](mailto:salimovalbert99@yandex.ru)

> Проект выполнен в рамках портфолио. Используемые технологии:  
> Django, PostgreSQL, Nginx, Docker, GitHub Actions, Prometheus, Grafana, Terraform, Ansible.

---

## Демо

Проект развернут на сервере `Yandex Cloud` и доступен по адресу:

**[http://51.250.40.100](http://51.250.40.100)**
