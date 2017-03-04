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
# Install falcon over a Debian 8.3 with squeezelite already installed via easetup.sh
#
################################################################################

function run_as_root() {
  [ "$(whoami)" == "root" ] || { 
    echo -e '\a\nWARNING: must be root.'
    exec su -c "$0"
  }
}

function install_git(){

	# install git and then clone falcon from github.
	apt-get install git
}
function clone_falcon(){

        if [ ! -d '/var/www' ]; then
		mkdir /var/www
        fi

	cd /var/www
	git clone https://github.com/marcoc1712/falcon.git

}
function pull_falcon(){

    cd /var/www/falcon
    git stash
    git pull

}
run_as_root	# run this first!
apt-get update
install_git

if [ ! -d '/var/www/falcon' ]; then
    clone_falcon
else
    pull_falcon
fi

chmod +x /var/www/falcon/falcon/resources/install/debian_ea/installer.sh
/var/www/falcon/falcon/resources/install/debian_ea/installer.sh