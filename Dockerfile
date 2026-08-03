FROM python:3.13-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.13-slim

RUN addgroup --system django && adduser --system --group --home /home/django django

COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

WORKDIR /app
COPY --chown=django:django . .

RUN python manage.py collectstatic --noinput --settings=CyberFraudQuiz.settings.prod && chmod +x entrypoint.sh

USER django

EXPOSE 8000

ENTRYPOINT ["./entrypoint.sh"]
