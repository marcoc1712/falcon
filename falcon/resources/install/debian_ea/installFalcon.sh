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

# install git and then falcon.
cd /var/www
apt-get install git
git clone https://github.com/marcoc1712/falcon.git

#sets execution capability to all the scripts.
chmod +x /var/www/falcon/cgi-bin/*.pl
chmod +x /var/www/falcon/exit/*.pl
chmod +x /var/www/falcon/falcon/default/exit/Standard/Linux/Debian_ea/*.pl
chmod +x /var/www/falcon/falcon/default/exit/Standard/Linux/*.pl
chmod +x /var/www/falcon/falcon/default/exit/myOwn/*.pl
chmod +x /var/www/falcon/falcon/default/exit/Examples/*.pl

# create exit directory
cd /var/www/falcon
mkdir exit
# copy example scripts
cp var/www/falcon/falcon/default/exit/Examples/*.pl var/www/falcon/exit/*.pl 

# create data directory
cd /var/www/falcon
mkdir data
chown www-data:www-data data

#set Falcon configuraton to DebianI386 default
ln -s  /var/www/falcon/falcon/default/conf/debianI386.conf  /var/www/falcon/data/falcon.conf

# create log directory
mkdir /var/log/falcon
chown www-data:www-data /var/log/falcon
touch /var/log/falcon/falcon.log
chown www-data:www-data /var/log/falcon/falcon.log
chmod g=rw /var/log/falcon/falcon.log

