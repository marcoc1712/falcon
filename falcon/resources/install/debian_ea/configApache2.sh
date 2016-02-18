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

# copia la configurazione del webserver Apache2
mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default-old.conf
cp /var/www/falcon/falcon/resources/install/WebServer/apache2/etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf

#abilita le CGI
ln -s /etc/apache2/mods-available/cgid.conf /etc/apache2/mods-enabled/cgid.conf
ln -s /etc/apache2/mods-available/cgid.load /etc/apache2/mods-enabled/cgid.load

