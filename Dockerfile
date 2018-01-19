FROM turbulent/heap-base:3.0.0
MAINTAINER Benoit Beausejour <b@turbulent.ca>

ENV heap-app 4.1.0

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y software-properties-common language-pack-en-base
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php

RUN apt-get update && \
    apt-get install -y \
      php7.1 \
      php7.1-apcu \
      php7.1-bcmath \
      php7.1-bz2 \
      php7.1-cli \
      php7.1-curl \
      php7.1-dba \
      php7.1-enchant \
      php7.1-fpm \
      php7.1-gd \
      php7.1-geoip \
      php7.1-gmp \
      php7.1-intl \
      php7.1-json \
      php7.1-ldap \
      php7.1-mbstring \
      php7.1-mcrypt \
      php7.1-memcached \
      php7.1-mysql \
      php7.1-odbc \
      php7.1-pgsql \
      php7.1-opcache \
      php7.1-readline \
      php7.1-soap \
      php7.1-sqlite3 \
      php7.1-tidy \
      php7.1-xml \
      php7.1-xmlrpc \
      php7.1-zip

RUN apt-get -y install time nginx zip imagemagick && \
  apt-get -y  remove ssmtp && \
  apt-get -y install bsd-mailx nullmailer && \
  apt-get -y install inotify-tools && \
  rm -rf /var/lib/apt/lists/*

RUN phpenmod mcrypt

COPY php-fpm /systpl/	
COPY nginx.conf.tmpl /systpl/
COPY nginx.app.conf.tmpl /systpl/
COPY supervisor.conf.tmpl /systpl/
COPY openssl-req.conf.tmpl /systpl/
COPY fastcgi_params.tmpl /systpl/

ADD run.sh /
ADD run-fpm.sh /
ADD run-nginx.sh /

ADD ffmpeg-bin-static /opt/ffmpeg/bin

RUN rm -rf /etc/php5/fpm/pool.d
COPY GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat

ADD OpCacheGUI /var/www/php-opcache-gui
ADD phpinfo.index.php /var/www/php-info/index.php

COPY nmailer-me.tmpl /systpl/
COPY nmailer-adminaddr.tmpl /systpl/
COPY nmailer-remotes.tmpl /systpl/
COPY nmailer-defaultdomain.tmpl /systpl/
ADD run-nullmailer.sh /
ADD imagemagick/policy.xml /etc/ImageMagick/policy.xml

RUN mkdir /tmp/php && \
  chmod 777 /tmp/php

ENV VAR_NGINX_WORKER_PROCESSES="4" \
  VAR_NGINX_WORKER_CONNECTIONS="1024" \
  VAR_NGINX_SERVER_NAME="dev.local" \
  VAR_NGINX_SERVER_ALIASES="[]" \
  VAR_NGINX_PORT="80" \
  VAR_NGINX_GZIP="true" \
  VAR_NGINX_LOADBALANCER_IPS="127.0.0.1" \
  VAR_NGINX_LOADBALANCER_HEADER="X-Forwarded-For" \
  VAR_NGINX_ALLOWED_IPS="" \
  VAR_NGINX_ALLOWED_HEAP_IPS="" \
  VAR_NGINX_MAX_BODY_SIZE="1500M" \
  VAR_NGINX_PROXY_READ_TIMEOUT="120" \
  VAR_NGINX_FASTCGI_READ_TIMEOUT="60" \
  VAR_NGINX_SSL="true" \
  VAR_NGINX_SSL_PEM="" \
  VAR_NGINX_SSL_REDIRECT="" \
  VAR_NGINX_SSL_REDIRECT_EXCEPTIONS='["/robots.txt"]' \
  VAR_NGINX_DOCROOT="/vol/website/docroot" \
  VAR_NGINX_AUTHMAP="" \
  VAR_NGINX_PROXYMAP="" \
  VAR_NGINX_UPSTREAMS="" \
  VAR_NGINX_CACHEMAP="" \
  VAR_NGINX_EXTRACONF="" \
  VAR_PHP_MAX_EXECUTION_TIME="60" \
  VAR_PHP_MEMORY_LIMIT="128M" \
  VAR_PHP_UPLOAD_MAX_FILESIZE="1024M" \
  VAR_PHP_POST_MAX_SIZE="1024M" \
  VAR_PHP_MAX_FILE_UPLOADS="1" \
  VAR_PHP_APC_SHM_SIZE="100M" \
  VAR_PHP_OPCACHE_MEMORY="128" \
  VAR_PHP_OPCACHE_REVALIDATE="2" \
  VAR_FPM_HOSTNAME="dev.local" \
  VAR_FPM="1" \
  VAR_FPM_PORT="80" \
  VAR_FPM_MAX_CHILDREN="10" \
  VAR_FPM_MIN_CHILDREN="10" \
  VAR_FPM_MAX_REQUESTS="4000" \
  VAR_FPM_REQUEST_TIMEOUT="120" \
  VAR_FPM_SLOWLOG="true" \
  VAR_FPM_SLOWLOG_TIMEOUT="120s" \
  VAR_NMAILER_HOSTNAME="hostname.example.com" \
  VAR_NMAILER_ROOT_ALIAS="sys@example.com" \
  VAR_NMAILER_DOMAIN="example.com" \
  VAR_NMAILER_REMOTE_HOST="smtp.example.com" \
  VAR_NMAILER_REMOTE_PORT="2525" \
  VAR_NMAILER_REMOTE_TLS="1" \
  VAR_NMAILER_REMOTE_USER="user@mandrillapp.com" \
  VAR_NMAILER_REMOTE_PASS="examplepass"


VOLUME ["/vol/logs"]
VOLUME ["/vol/spool"]
VOLUME ["/usr/share/GeoIP"]

EXPOSE 80
CMD ["/run.sh"]
