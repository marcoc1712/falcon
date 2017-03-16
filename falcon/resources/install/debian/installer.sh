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
# Please use InstallFalcon.sh to install git and clone/pull repository from github.
# It will call this script at the end.
#
##############################################################################

function run_as_root() {
  [ "$(whoami)" == "root" ] || { 
    echo -e '\a\nWARNING: must be root.'
    exec su -c "$0"
  }
}

function install_falcon(){

	# create exit directory
	cd /var/www/falcon
	if [ ! -d '/var/www/falcon/exit' ]; then
		mkdir exit
		ln -s /var/www/falcon/falcon/default/exit/Examples/setWakeOnLan.pl /var/www/falcon/exit/setWakeOnLan.pl 
		ln -s /var/www/falcon/falcon/default/exit/Examples/testAudioDevice.pl /var/www/falcon/exit/testAudioDevice.pl 
	fi
	
	if [ ! -d '/var/www/falcon/data' ]; then
		cd /var/www/falcon
		mkdir data
		chown www-data:www-data data

		#set Falcon configuraton to debianI386 default
		cp  /var/www/falcon/falcon/default/conf/debianI386.conf  /var/www/falcon/data/falcon.conf
        chown www-data:www-data /var/www/falcon/data/falcon.conf
	fi
    
	if [ ! -d '/var/log/falcon' ]; then
		# create log directory
		mkdir /var/log/falcon
		chown www-data:www-data /var/log/falcon
		touch /var/log/falcon/falcon.log
		chown www-data:www-data /var/log/falcon/falcon.log
		chmod g=rw /var/log/falcon/falcon.log
		### TODO: Attivare la rotazione dei files di log.
	fi
}

function set_scripts_permissions(){
    
    #sets execution capability to all the scripts.
    chmod +x /var/www/falcon/cgi-bin/*.pl
    chmod +x /var/www/falcon/exit/*.pl
    chmod +x /var/www/falcon/falcon/default/exit/standard/linux/debian/*.pl
    chmod +x /var/www/falcon/falcon/default/exit/standard/linux/*.pl
    chmod +x /var/www/falcon/falcon/default/exit/myOwn/*.pl
    chmod +x /var/www/falcon/falcon/default/exit/Examples/*.pl
    # 
    chmod +x /var/www/falcon/falcon/resources/install/debian/*.sh

}
function additional_settings(){

    ## aggiunge www-data al gruppo audio, così da vedere tutti i dispositivi.
    adduser www-data audio
 
    # corregge un errore di versioni precedenti.
    if [ -L '/var/www/falcon/data/falcon.conf' ]; then
        rm /var/www/falcon/data/falcon.conf
        cp  /var/www/falcon/falcon/default/conf/debianI386.conf  /var/www/falcon/data/falcon.conf
    fi
    chown www-data:www-data /var/www/falcon/data/falcon.conf

    #verifica se squeezelite-R2 è stato installato con eaSetup, altrimenti reinstalla.
    if [ ! -e '/usr/bin/squeezelite' ] || [ ! -e '/etc/default/squeezelite' ] || 
       [ ! -e '/etc/init.d/squeezelite' ]; then

       /var/www/falcon/falcon/resources/install/debian/install_squeezelite.sh

    fi

    ### accesso in scrittura a etc/default/squeezelite (ed eventualmente al backup da creare come /etc/default/squeezelite.wbak)
    if [ ! -e '/etc/default/squeezelite.wbak' ]; then
        cp /etc/default/squeezelite /etc/default/squeezelite.wbak
    fi

    chown www-data:www-data /etc/default/squeezelite
    chmod g=rw /etc/default/squeezelite

    systemctl daemon-reload

    ###
    ### accesso in scrittura al file di log ( ed eventualmente ai files di backup e rotazione,se la si vuole attivare).
    
    if [ ! -d '/var/log/squeezelite-R2' ]; then
        mkdir /var/log/squeezelite-R2
    fi
    chown www-data:www-data  /var/log/squeezelite-R2
    touch  /var/log/squeezelite-R2/squeezelite-R2.log
    chown www-data:www-data /var/log/squeezelite-R2/squeezelite-R2.log
    chmod g=rw /var/log/squeezelite-R2/squeezelite-R2.log
    ### TODO: Attivare la rotazione dei files di log.

    ###
    ### Installa chkconfig per l'autostart.
    apt-get install chkconfig

    ### Shutdown, bisogna essere root.                              -> visudo
    ### Reboot, bisogna essere root (?)                             -> visudo
    ### Service squeezelite (start,stop,restart) accesso negato.    -> visudo
    ### update-rc.d (autostart) accesso negato                      -> visudo

    if [ ! -e '/etc/sudoers.d' ]; then
        apt-get install sudo
    fi

    if [ -e '/etc/sudoers.d/falcon' ]; then
        rm /etc/sudoers.d/falcon
    fi
    cp /var/www/falcon/falcon/resources/install/debian/systemRoot/etc/sudoers.d/falcon /etc/sudoers.d/falcon
    chown root:root /etc/sudoers.d/falcon 
    chmod 440 /etc/sudoers.d/falcon

}
function install_apache2(){

     apt-get install apache2
}
function config_apache2(){

    # copia la configurazione del webserver Apache2
    if [ ! -e '/etc/apache2/sites-available/000-default-old.conf' ]; then
        mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default-old.conf
    
    else
        rm /etc/apache2/sites-available/000-default.conf
    fi 
    cp /var/www/falcon/falcon/resources/install/webServer/apache2/etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf
    ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf

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
    mv /var/www/falcon/falcon/resources/install/webServer/lighttpd/etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf 
}
##############################################################################
## MAIN
##############################################################################
run_as_root	# run this first!

install_falcon
set_scripts_permissions
additional_settings

if [ -d '/etc/lighttpd' ]; then
    config_lighttpd
    service lighttpd restart
elif [ -d '/etc/apache2' ]; then
    config_apache2
    service apache2 restart
else
    install_apache2
    config_apache2
    service apache2 restart
fi
# END #########################################################################