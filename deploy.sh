#!/bin/sh

ENV_FILE=".env"
SECRETS_FILE=".env.generated"

wget -q -O docker-compose.yml https://raw.githubusercontent.com/AlbertSalimov/CyberFraudQuiz/refs/heads/main/docker-compose.yml
wget -q -O $ENV_FILE https://raw.githubusercontent.com/AlbertSalimov/CyberFraudQuiz/refs/heads/main/.env.example
wget -q -O nginx.conf https://raw.githubusercontent.com/AlbertSalimov/CyberFraudQuiz/refs/heads/main/nginx.conf
wget -q -O prometheus.yml https://raw.githubusercontent.com/AlbertSalimov/CyberFraudQuiz/refs/heads/main/prometheus.yml
wget -q -O grafana.ini https://raw.githubusercontent.com/AlbertSalimov/CyberFraudQuiz/refs/heads/main/grafana.ini

if [ ! -f $SECRETS_FILE ]; then
    NEW_DB_USER=$(openssl rand -base64 6 | tr -d '+/' | cut -c1-8)
    NEW_DB_PASSWORD=$(openssl rand -base64 32 | tr -d '\n' | tr -d '+/' | cut -c1-32)
    ESCAPED_DB_PASSWORD=$(printf '%s\n' "$NEW_DB_PASSWORD" | sed 's/[\/&]/\\&/g')
    NEW_SECRET_KEY=$(openssl rand -base64 32 | tr -d '\n' | tr -d '+/' | cut -c1-50)
    ESCAPED_SECRET_KEY=$(printf '%s\n' "$NEW_SECRET_KEY" | sed 's/[\/&]/\\&/g')

    cat > $SECRETS_FILE <<EOF
NEW_DB_USER=$NEW_DB_USER
ESCAPED_DB_PASSWORD=$ESCAPED_DB_PASSWORD
ESCAPED_SECRET_KEY=$ESCAPED_SECRET_KEY
EOF
else
    export $(grep -v '^#' $SECRETS_FILE | xargs)
fi

SERVER_IP=$(curl -s 2ip.io)

sed -i "s/^DB_USER=.*/DB_USER=$NEW_DB_USER/" $ENV_FILE
sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$ESCAPED_DB_PASSWORD/" $ENV_FILE
sed -i "s/^SECRET_KEY=.*/SECRET_KEY=$ESCAPED_SECRET_KEY/" $ENV_FILE
sed -i "s/^ALLOWED_HOSTS=\(.*\)/ALLOWED_HOSTS=\1,$SERVER_IP/" $ENV_FILE
sed -i "s|^CSRF_TRUSTED_ORIGINS=.*|CSRF_TRUSTED_ORIGINS=http://$SERVER_IP|" $ENV_FILE

docker compose pull
docker compose up -d
