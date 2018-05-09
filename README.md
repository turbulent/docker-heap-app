# heap-app docker image

This Dockerfile is the typical container for running a Heap application. It
contains an nginx webserver exposing port 80 and 443 and a PHP-FPM fastcgi
process for processing PHP files. The supervisor daemon is the main entrypoint
and manages respawn and restarts of the nginx/fpm subprocesses inside the
container.

This image is based upon the heap-base docker image.

## Usage

```
$ docker run -d -p 80:80 heap-app 
```

You can pass envrionment variables when launching the container:

```
$ docker run -d -e "VAR_NGINX_WORKER_PROCESSES=4" -e "VAR_NGINX_SERVER_NAME=foo.com" -p 80:80 heap-app 
```

Sample with SSL activated:

```
$ docker run -d \
  -e "VAR_NGINX_SSL_PEM=`cat ssl.pem`" \
  -e "VAR_NGINX_SSL_REDIRECT=true" \
  -e "VAR_NGINX_SSL_REDIRECT_EXCEPTIONS='["/api/forum","/api/chat"]'" \
  -p 80:80 -p 443:443 heap-app
```

## Environment variables

This image uses environment variables to override common configuration options.

The following environment variables are available (listed below with default values):

SSMTP options:

```
VAR_SSMTP_ROOT_ALIAS="sys@turbulent.ca"
VAR_SSMTP_MAILHUB="localhost"
VAR_SSMTP_HOSTNAME="localhost"
VAR_SSMTP_AUTH_USERNAME=""
VAR_SSMTP_AUTH_PASSWORD=""
VAR_SSMTP_SSL="1"
```

nginx options:

```
VAR_NGINX_WORKER_PROCESSES="4"
VAR_NGINX_WORKER_CONNECTIONS="1024"
VAR_NGINX_SERVER_NAME=""
VAR_NGINX_PORT="80"
VAR_NGINX_GZIP="true"
VAR_NGINX_LOADBALANCER_HEADER="X-Forwarded-For"
VAR_NGINX_ALLOWED_IPS=""
VAR_NGINX_ALLOWED_HEAP_IPS=""
VAR_NGINX_MAX_BODY_SIZE="1500M"
VAR_NGINX_PROXY_READ_TIMEOUT="120"
VAR_NGINX_SSL_PEM=""
VAR_NGINX_SSL_REDIRECT="" #boolean
VAR_NGINX_REAL_IP_RECURSIVE="" #boolean

JSON based option:
VAR_NGINX_SSL_REDIRECT_EXCEPTIONS='["url","url"]'
VAR_NGINX_LOADBALANCER_IPS='["ip","ip"]'
VAR_NGINX_SERVER_ALIASES='["url.example.com", "url2.example.com"]'

VAR_NGINX_UPSTREAMS=[{"name":"upstreamname","servers":["server.destination.com"]}]
VAR_NGINX_PROXYMAP=[{"location":"/matchuri","destination":"http://destinationurl"}]
VAR_NGINX_REDIRECTMAP=[{"location":"/matchuri", "destination":"/destinationuri"}]
VAR_NGINX_AUTHMAP=[{"location":"/api", authfile:null},{"location":"/", "authfile":"/vol/htaccess.conf"}]
VAR_NGINX_CACHEMAP=[{"location":"*.jpg","expires":"modified 10d"}]
```

php-fpm options:

```
VAR_PHP_MAX_EXECUTION_TIME="60"
VAR_PHP_MEMORY_LIMIT="128M"
VAR_PHP_UPLOAD_MAX_FILESIZE="1024M"
VAR_PHP_POST_MAX_SIZE="1024M"
VAR_PHP_MAX_FILE_UPLOADS="1"
VAR_PHP_APC_SHM_SIZE="100M"
VAR_FPM_PORT="80"
VAR_FPM_MAX_CHILDREN="10"
VAR_FPM_MIN_CHILDREN="10"
VAR_FPM_MAX_REQUESTS="4000"
VAR_FPM_REQUEST_TIMEOUT="120"
VAR_FPM_SLOWLOG="true"
VAR_FPM_SLOWLOG_TIMEOUT="120s"
```

## License

This Dockerfile packages the [OpCacheGUI](https://github.com/PeeHaa/OpCacheGUI)
source code, which is available under the [MIT
License](http://spdx.org/licenses/MIT). OpCacheGUI is developed by Pieter
Hordijk.

This Dockerfile packages a compiled binary of [FFmpeg](https://www.ffmpeg.org).
FFmpeg is licensed under the [GNU General Public
License](http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html) or later. You
can freely replace this binary by running the container while specifying
a volume at the path `/opt/ffmpeg/bin/ffmpeg-bin-static` like so:

```
$ docker run -v /path/to/my/ffmpeg:/opt/ffmpeg/bin/ffmpeg-bin-static turbulent/heap-app
```

This product includes GeoLite data created by MaxMind, available from
[http://www.maxmind.com](http://www.maxmind.com).

All other work found under this repository is licensed under the [Apache License 2.0](LICENSE).

