#!/bin/bash
#
# WEB INTERFACE and Controll application for an headless squeezelite
# installation.
#
# Best used with Squeezelite-R2 
# (https://github.com/marcoc1712/squeezelite/releases)
#
# Copyright 2016 Marco Curti, marcoc1712 at gmail dot com.
# Please visit www.marcoc1712.it
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
################################################################################
#
# Falcon install over a Debian 8.3 with squeezelite already installed via easetup.sh
#
##############################################################################

function run_as_root() {
  [ "$(whoami)" == "root" ] || { 
    echo -e '\a\nWARNING: must be root.'
    exec su -c "$0"
  }
}

##############################################################################
run_as_root	# run this first!

### aggiunge www-data al gruppo audio, così da vedere tutti i dispositivi.
adduser www-data audio
### 
### accesso in scrittura a etc/default/squeezelite (ed eventualmente al backup da creare come /etc/default/squeezelite.wbak)
cp /etc/default/squeezelite /etc/default/squeezelite.wbak
chown www-data:www-data /etc/default/squeezelite
chmod g=rw /etc/default/squeezelite

###
### accesso in scrittura al file di log ( ed eventualmente ai files di backup e rotazione,se la si vuole attivare).
mkdir /var/log/squeezelite-R2
chown www-data:www-data  /var/log/squeezelite-R2
touch  /var/log/squeezelite-R2/squeezelite-R2.log
chown www-data:www-data /var/log/squeezelite-R2/squeezelite-R2.log
chmod g=rw /var/log/squeezelite-R2/squeezelite-R2.log
###
###
### Installa chkconfig per l'autostart.
apt-get install chkconfig

### Shutdown, bisogna essere root.									-> visudo
### Reboot, bisogna essere root (?)									-> visudo
### Service xqueezelite (start,stop,restart) accesso negato.		-> visudo
### update-rc.d (autostart) accesso negato							-> visudo

###
### problema (aggirato) dei permessi alla creazione dei nuovi files creati da root nelle cartelle di proprietà www-data
### bisogna impostare umask? a che valore?
###
### TODO: Attivare la rotazione dei files di log.
