#!/bin/bash -e

touch /vol/logs/${HOSTNAME}-php-error.log && chown heap:www-data /vol/logs/${HOSTNAME}-php-error.log
touch /vol/logs/${HOSTNAME}-php-slow.log && chown heap:www-data /vol/logs/${HOSTNAME}-php-slow.log
touch /vol/logs/${HOSTNAME}-php-fpm.log && chown heap:www-data /vol/logs/${HOSTNAME}-php-fpm.log

/systpl/systpl.jinja.py /systpl/fpm-php.ini.tmpl > /etc/php/8.1/fpm/php.ini
/systpl/systpl.jinja.py /systpl/php-fpm.conf.tmpl > /etc/php/8.1/fpm/php-fpm.conf
/systpl/systpl.jinja.py /systpl/apc.ini.tmpl > /etc/php/8.1/mods-available/apcu.ini
/systpl/systpl.jinja.py /systpl/opcache.ini.tmpl > /etc/php/8.1/mods-available/opcache.ini

env | awk 'BEGIN { FS="=" } /^VAR_.*=.+/ { print "env[" $1 "]='\''" $2 "'\''" }' > /etc/php/8.1/fpm/env.conf

exec /usr/sbin/php-fpm8.1 -F
