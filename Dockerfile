FROM turbulent/heap-base:4.0.1
MAINTAINER Benoit Beausejour <b@turbulent.ca>

ENV heap-app 6.1.1

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y software-properties-common language-pack-en-base
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php

RUN apt-get update && \
  apt-get install -y \
  bsd-mailx \
  inotify-tools \
  nginx \
  nullmailer \
  time \
  zip \
  wget \
  php7.4 \
  php7.4-apcu \
  php7.4-apcu-bc \
  php7.4-bcmath \
  php7.4-bz2 \
  php7.4-cli \
  php7.4-curl \
  php7.4-dba \
  php7.4-enchant \
  php7.4-fpm \
  php7.4-gd \
  php7.4-geoip \
  php7.4-gmp \
  php7.4-intl \
  php7.4-json \
  php7.4-ldap \
  php7.4-mbstring \
  php7.4-memcached \
  php7.4-mysql \
  php7.4-odbc \
  php7.4-pgsql \
  php7.4-opcache \
  php7.4-readline \
  php7.4-redis \
  php7.4-soap \
  php7.4-sqlite3 \
  php7.4-tidy \
  php7.4-xml \
  php7.4-xmlrpc \
  php7.4-yaml \
  php7.4-zip \
  php-pear \
  php7.4-dev \
  librdkafka-dev \
  && pecl install rdkafka grpc \
  && apt-get remove -y php-pear php7.4-dev linux-headers \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && echo "extension = rdkafka.so" > /etc/php/7.4/mods-available/rdkafka.ini \
  && echo "extension = grpc.so" > /etc/php/7.4/mods-available/grpc.ini \
  && phpenmod rdkafka \
  && phpenmod grpc

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

COPY GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat

ADD opcache-gui /var/www/php-opcache-gui
ADD phpinfo.index.php /var/www/php-info/index.php

COPY nmailer-me.tmpl /systpl/
COPY nmailer-adminaddr.tmpl /systpl/
COPY nmailer-remotes.tmpl /systpl/
COPY nmailer-defaultdomain.tmpl /systpl/
ADD run-nullmailer.sh /

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
  VAR_NMAILER_REMOTE_PASS="examplepass" \
  VAR_FPM_CATCH_WORKERS_OUTPUT="no"

RUN wget -O - https://download.newrelic.com/548C16BF.gpg | apt-key add -
RUN sh -c 'echo "deb http://apt.newrelic.com/debian/ newrelic non-free" \
  > /etc/apt/sources.list.d/newrelic.list'

RUN apt-get update \
  && apt-get install -y newrelic-php5 \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

COPY newrelic.ini.tmpl /systpl/

# Install ImageMagick 7.1 https://github.com/dooman87/imagemagick-docker/blob/main/Dockerfile.ubuntu
ARG IM_VERSION=7.1.0-51
ARG LIB_HEIF_VERSION=1.13.0
ARG LIB_AOM_VERSION=3.5.0
ARG LIB_WEBP_VERSION=1.2.4
ARG LIBJXL_VERSION=0.7.0

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y git make gcc pkg-config autoconf curl g++ cmake clang \
    # libaom
    yasm \
    # libheif
    libde265-0 libde265-dev libjpeg-turbo8-dev x265 libx265-dev libtool \
    # libwebp
    libsdl1.2-dev libgif-dev \
    # libjxl
    libbrotli-dev \
    # IM
    libpng16-16 libpng-dev libgomp1 ghostscript libxml2-dev libxml2-utils libtiff-dev libfontconfig1-dev libfreetype6-dev fonts-dejavu liblcms2-dev \
    # Install manually to prevent deleting with -dev packages
    libxext6 libbrotli1 && \
    # Building libjxl
    export CC=clang CXX=clang++ && \
    git clone -b v${LIBJXL_VERSION} https://github.com/libjxl/libjxl.git --depth 1 --recursive --shallow-submodules && \
    cd libjxl && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF .. && \
    cmake --build . -- -j$(nproc) && \
    cmake --install . && \
    cd ../../ && \
    rm -rf libjxl && \
    ldconfig /usr/local/lib && \
    # Building libwebp
    git clone https://chromium.googlesource.com/webm/libwebp && \
    cd libwebp && git checkout v${LIB_WEBP_VERSION} && \
    ./autogen.sh && ./configure --enable-shared --enable-libwebpdecoder --enable-libwebpdemux --enable-libwebpmux --enable-static=no && \
    make && make install && \
    ldconfig /usr/local/lib && \
    cd ../ && rm -rf libwebp && \
    # Building libaom
    git clone -b v${LIB_AOM_VERSION} --depth 1 https://aomedia.googlesource.com/aom && \
    mkdir build_aom && \
    cd build_aom && \
    cmake ../aom/ -DENABLE_TESTS=0 -DBUILD_SHARED_LIBS=1 && make && make install && \
    ldconfig /usr/local/lib && \
    cd .. && \
    rm -rf aom && \
    rm -rf build_aom && \
    # Building libheif
    curl -L https://github.com/strukturag/libheif/releases/download/v${LIB_HEIF_VERSION}/libheif-${LIB_HEIF_VERSION}.tar.gz -o libheif.tar.gz && \
    tar -xzvf libheif.tar.gz && cd libheif-${LIB_HEIF_VERSION}/ && ./autogen.sh && ./configure && make && make install && cd .. && \
    ldconfig /usr/local/lib && \
    rm -rf libheif-${LIB_HEIF_VERSION} && rm libheif.tar.gz && \
    # Building ImageMagick
    git clone -b ${IM_VERSION} --depth 1 https://github.com/ImageMagick/ImageMagick.git && \
    cd ImageMagick && \
    ./configure --without-magick-plus-plus --disable-docs --disable-static --with-tiff --with-jxl && \
    make && make install && \
    ldconfig /usr/local/lib && \
    apt-get remove --autoremove --purge -y gcc make cmake clang curl g++ yasm git autoconf pkg-config libpng-dev libjpeg-turbo8-dev libde265-dev libx265-dev libxml2-dev libtiff-dev libfontconfig1-dev libfreetype6-dev liblcms2-dev libsdl1.2-dev libgif-dev libbrotli-dev && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /ImageMagick

ADD imagemagick/policy.xml /usr/local/etc/ImageMagick-7/policy.xml

VOLUME ["/vol/logs"]
VOLUME ["/vol/spool"]

EXPOSE 80
CMD ["/run.sh"]
