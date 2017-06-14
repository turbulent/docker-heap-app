#!//bin/bash

if [[ ! -z $VAR_NGINX_SSL && $VAR_NGINX_SSL_PEM ]]; then
  echo "Using supplied SSL PEM"
  echo "$VAR_NGINX_SSL_PEM" > /etc/nginx/ssl.pem
  export VAR_NGINX_SSL_PEM="***cleared***"
elif [[ ! -z $VAR_NGINX_SSL ]]; then
  echo "Generating self-signed certificate : ${VAR_NGINX_SERVER_NAME}..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl.pem -out /etc/nginx/ssl.pem -config /etc/nginx/openssl-req.conf

fi

echo "Starting nginx..."
exec /usr/sbin/nginx
