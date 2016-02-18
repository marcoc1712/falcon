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

function install_git(){

    # install git and then falcon.
    cd /var/www
    apt-get install git
}

function install_falcon(){

    # install git and then falcon.
    cd /var/www
    git clone https://github.com/marcoc1712/falcon.git

    # create exit directory
    cd /var/www/falcon
    mkdir exit
    # copy example scripts
    ln -s /var/www/falcon/falcon/default/exit/Examples/setWakeOnLan.pl /var/www/falcon/exit/setWakeOnLan.pl 
    ln -s /var/www/falcon/falcon/default/exit/Examples/testAudioDevice.pl /var/www/falcon/exit/testAudioDevice.pl 

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

}

function update_falcon(){

    cd /var/www/falcon
    git stash
    git pull

}
function set_scripts_permissions(){
    
    #sets execution capability to all the scripts.
    chmod +x /var/www/falcon/cgi-bin/*.pl
    chmod +x /var/www/falcon/exit/*.pl
    chmod +x /var/www/falcon/falcon/default/exit/Standard/Linux/Debian_ea/*.pl
    chmod +x /var/www/falcon/falcon/default/exit/Standard/Linux/*.pl
    chmod +x /var/www/falcon/falcon/default/exit/myOwn/*.pl
    chmod +x /var/www/falcon/falcon/default/exit/Examples/*.pl
    # 
    chmod +x /var/www/falcon/falcon/resources/install/debian_ea/*.sh

}
function install_apache2(){

     apt-get install apache2
}
function config_apache2(){

    # copia la configurazione del webserver Apache2
    if [ ! -e '/etc/lighttpd/lighttpd-old.conf' ]; then
        mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default-old.conf
    
    else
        rm /etc/apache2/sites-available/000-default.conf
    fi 
    cp /var/www/falcon/falcon/resources/install/WebServer/apache2/etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf

    #abilita le CGI
    ln -s /etc/apache2/mods-available/cgid.conf /etc/apache2/mods-enabled/cgid.conf
    ln -s /etc/apache2/mods-available/cgid.load /etc/apache2/mods-enabled/cgid.load
}

function config_lighttpd(){

    # copia la configurazione del webserver lighttpd
    if [ ! -e '/etc/lighttpd/lighttpd-old.conf' ]; then
        mv /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd-old.conf
    else
        rm /etc/lighttpd/lighttpd.conf
    fi 
    mv /var/www/falcon/falcon/resources/install/WebServer/lighttpd/etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf 

}
function additional_settings(){

    ## aggiunge www-data al gruppo audio, così da vedere tutti i dispositivi.
    adduser www-data audio
    ### 
    ### accesso in scrittura a etc/default/squeezelite (ed eventualmente al backup da creare come /etc/default/squeezelite.wbak)
    
    if [ ! -e '/etc/default/squeezelite.wbak' ]; then
        cp /etc/default/squeezelite /etc/default/squeezelite.wbak
    fi

    chown www-data:www-data /etc/default/squeezelite
    chmod g=rw /etc/default/squeezelite

    ###
    ### accesso in scrittura al file di log ( ed eventualmente ai files di backup e rotazione,se la si vuole attivare).
    
    if [ ! -d '/var/log/squeezelite-R2' ]; then
        mkdir /var/log/squeezelite-R2
    fi
    chown www-data:www-data  /var/log/squeezelite-R2
    touch  /var/log/squeezelite-R2/squeezelite-R2.log
    chown www-data:www-data /var/log/squeezelite-R2/squeezelite-R2.log
    chmod g=rw /var/log/squeezelite-R2/squeezelite-R2.log
    ###
    ###
    ### Installa chkconfig per l'autostart.
    apt-get install chkconfig

    ### Shutdown, bisogna essere root.                              -> visudo
    ### Reboot, bisogna essere root (?)                             -> visudo
    ### Service xqueezelite (start,stop,restart) accesso negato.    -> visudo
    ### update-rc.d (autostart) accesso negato                      -> visudo
    
    if [ -e '/etc/default/squeezelite.wbak' ]; then
        rm /etc/sudoers.d/falcon
    fi
    cp /var/www/falcon/falcon/resources/install/debian_ea/System/etc/sudoers.d/falcon /etc/sudoers.d/falcon
    chown root:root /etc/sudoers.d/falcon 
    chmod 440 /etc/sudoers.d/falcon
    
    ### TODO:
    ### problema (aggirato) dei permessi alla creazione dei nuovi files creati da root nelle cartelle di proprietà www-data
    ### bisogna impostare umask? a che valore?
    ###
    ### TODO: Attivare la rotazione dei files di log.

}

##############################################################################
run_as_root	# run this first!

apt-get update

install_git

if [ -d '/var/www/falcon' ]; then
    update_falcon
else
    install_falcon
fi

set_scripts_permissions

if [ -d '/etc/lighttpd' ]; then
    config_lighttpd
elif [ -d '/etc/apache2' ]; then
    config_apache2
else
    install_apache2
    config_apache2
fi

additional_settings




