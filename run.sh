#!/bin/bash

/systpl/systpl.jinja.py /systpl/supervisor.conf.tmpl > /etc/supervisor.conf

#nginx config
/systpl/systpl.jinja.py /systpl/openssl-req.conf.tmpl > /etc/nginx/openssl-req.conf
/systpl/systpl.jinja.py /systpl/nginx.conf.tmpl > /etc/nginx/nginx.conf
/systpl/systpl.jinja.py /systpl/nginx.app.conf.tmpl > /etc/nginx/nginx.app.conf
/systpl/systpl.jinja.py /systpl/fastcgi_params.tmpl > /etc/nginx/fastcgi_params

#FPM and PHP configs
/systpl/systpl.jinja.py /systpl/cli-php.ini.tmpl > /etc/php/8.1/cli/php.ini
/systpl/systpl.jinja.py /systpl/fpm-php.ini.tmpl > /etc/php/8.1/fpm/php.ini
/systpl/systpl.jinja.py /systpl/php-fpm.conf.tmpl > /etc/php/8.1/fpm/php-fpm.conf
/systpl/systpl.jinja.py /systpl/apc.ini.tmpl > /etc/php/8.1/mods-available/apcu.ini
/systpl/systpl.jinja.py /systpl/newrelic.ini.tmpl > /etc/php/8.1/mods-available/newrelic.ini

exec supervisord -c /etc/supervisor.conf
