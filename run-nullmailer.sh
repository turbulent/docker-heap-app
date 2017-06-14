#!/bin/bash

/systpl/systpl.jinja.py /systpl/nmailer-defaultdomain.tmpl > /etc/nullmailer/defaultdomain
/systpl/systpl.jinja.py /systpl/nmailer-me.tmpl > /etc/nullmailer/me
/systpl/systpl.jinja.py /systpl/nmailer-remotes.tmpl > /etc/nullmailer/remotes
/systpl/systpl.jinja.py /systpl/nmailer-adminaddr.tmpl > /etc/nullmailer/adminaddr

#initialize the nullmailer trigger and spool dirs into the pesistent volume.
BASEDIR=/vol/spool/${HOSTNAME}-nullmailer

mkdir -p ${BASEDIR}
chown mail:root ${BASEDIR}
chmod 755 ${BASEDIR}

rm -f ${BASEDIR}/trigger
mkfifo ${BASEDIR}/trigger
chown mail:root ${BASEDIR}/trigger
chmod 0622 ${BASEDIR}/trigger

mkdir -p ${BASEDIR}/queue 
chown mail:root ${BASEDIR}/queue
chmod -R 750 ${BASEDIR}/queue

mkdir -p ${BASEDIR}/tmp 
chown mail:root ${BASEDIR}/tmp
chmod -R 750 ${BASEDIR}/tmp

rm -rf /var/spool/nullmailer
ln -s ${BASEDIR} /var/spool/nullmailer

cd /var/mail
exec nullmailer-send

exec start-stop-daemon --start --user mail --chuid mail --oknodo --exec nullmailer-send
