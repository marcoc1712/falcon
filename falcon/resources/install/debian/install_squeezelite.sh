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
# Squeezelite Install without pakages or scripts in a Debian based systems
#
################################################################################

function run_as_root() {
  [ "$(whoami)" == "root" ] || { 
    echo -e '\a\nWARNING: must be root.'
    exec su -c "$0"
  }
}

function download_squeezelite_r2() {
    
    cd /usr/bin
    if [ -e '/usr/bin/squeezelite' ]; then
        mv '/usr/bin/squeezelite' '/usr/bin/squeezelite.wbak'
    fi

    if [ -e '/usr/bin/squeezelite-R2' ]; then
        mv '/usr/bin/squeezelite-R2' '/usr/bin/squeezelite-R2.wbak'
    fi

    arc="$(uname -m)"

    if [ $arc == "i386" ]; then
     
        wget "http://github.com/marcoc1712/squeezelite-R2/releases/download/v1.8.3-(R2)/squeezelite-R2-min-i386"
        mv 'squeezelite-R2-min-i386' '/usr/bin/squeezelite-R2'

    elif[ $arc == "x86_64" ]; then
        
        wget "https://github.com/marcoc1712/squeezelite-R2/releases/download/v1.8.3-(R2)/squeezelite-R2-min-x86_64"
        mv 'squeezelite-R2-min-i386' '/usr/bin/squeezelite-R2'
        
    fi 

    ln -s '/usr/bin/squeezelite-R2' '/usr/bin/squeezelite'
    chmod +x '/usr/bin/squeezelite-R2'

}
function setup_autostart() {
    
    if [ -e '/etc/default/squeezelite' ]; then
        mv '/etc/default/squeezelite' '/etc/default/squeezelite.wbak'
    fi

    if [ -e '/etc/init.d/squeezelite' ]; then
        mv '/etc/init.d/squeezelite' '/etc/init.d/squeezelite.wbak'
    fi

    cp /var/www/falcon/falcon/resources/install/debian/systemRoot/etc/default/squeezelite /etc/default/squeezelite
    cp /var/www/falcon/falcon/resources/install/debian/systemRoot/etc/init.d/squeezelite /etc/init.d/squeezelite
    
    chmod +x "/etc/init.d/squeezelite"

    update-rc.d squeezelite defaults
    invoke-rc.d squeezelite start 2 3 4 5

}

##############################################################################
## MAIN
##############################################################################

run_as_root	# run this first!
download_squeezelite_r2
setup_autostart

# END #########################################################################