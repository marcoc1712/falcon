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
# Falcon update.
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

# stash is used to avid errors due to local modifications as chmod on scripts
# or erroneus modifictaion outside the exit folder.

cd /var/www/falcon
git stash
git pull

#sets execution capability to all the scripts.
chmod +x /var/www/falcon/cgi-bin/*.pl
chmod +x /var/www/falcon/exit/*.pl
chmod +x /var/www/falcon/falcon/default/exit/Standard/Linux/Debian_ea/*.pl
chmod +x /var/www/falcon/falcon/default/exit/Standard/Linux/*.pl
chmod +x /var/www/falcon/falcon/default/exit/myOwn/*.pl
chmod +x /var/www/falcon/falcon/default/exit/Examples/*.pl
# 
chmod +x /var/www/falcon/falcon/resources/install/debian_ea/*.sh