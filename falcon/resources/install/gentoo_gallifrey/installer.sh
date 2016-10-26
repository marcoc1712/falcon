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
# Install falcon over a gentoo x86_64 with squeezelite-R2 already installed via the 
# ebuild in gallifrey overlay : 
# https://raw.githubusercontent.com/fedeliallalinea/gallifrey/master/repositories.xml
#
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

		#set Falcon configuraton to DebianI386 default
		ln -s  /var/www/falcon/falcon/default/conf/gentoox86.conf  /var/www/falcon/data/falcon.conf
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
    chmod +x /var/www/falcon/falcon/default/exit/Standard/Linux/gentoo_gallifrey/*.pl
    chmod +x /var/www/falcon/falcon/default/exit/Standard/Linux/*.pl
    chmod +x /var/www/falcon/falcon/default/exit/myOwn/*.pl
    chmod +x /var/www/falcon/falcon/default/exit/Examples/*.pl
    # 
    chmod +x /var/www/falcon/falcon/resources/install/gentoo_gallifrey/*.sh

}
function additional_settings(){

    ## aggiunge squeezelite al gruppo audio, cosi da vedere tutti i dispositivi ed
    ## al gruppo realtime per usufruirne.

    usermod -g squeezelite -aG audio,realtime squeezelite

    ## aggiunge www-data  al gruppo audio, cosi da vedere tutti i dispositivi ed al
    ## gruppo squeezelite, cosi da poter accedere ai files di log ed altri
    ## creati da squeezelite.

    usermod -g www-data -aG audio,squeezelite www-data
    
    ### 
    ### accesso in scrittura a etc/conf.d/squeezelite (ed eventualmente al backup da creare come /etc/default/squeezelite.wbak)
    
    if [ ! -e '/etc/conf.d/squeezelite-R2.wbak' ]; then
        cp /etc/conf.d/squeezelite-R2 /etc/conf.d/squeezelite-R2.wbak
    fi

    chown root:www-data /etc/conf.d/squeezelite-R2
    chmod g=rw /etc/conf.d/squeezelite-R2
    chmod o=r /etc/conf.d/squeezelite-R2

    ### Attenzione, init.d si riprende sempre possesso eslclusivo di 
    ###
    ### accesso in scrittura al file di log ( ed eventualmente ai files di backup e rotazione,se la si vuole attivare).
    ### 

    #if [ ! -d '/var/log/squeezelite-R2' ]; then
    #    mkdir /var/log/squeezelite-R2
    #fi
    #chown root:squeezelite  /var/log/squeezelite-R2
    ### TODO: Attivare la rotazione dei files di log.

    touch  /var/log/squeezelite-R2.log
    chown root:squeezelite /var/log/squeezelite-R2.log
    chmod g=rw /var/log/squeezelite-R2.log
   
    # installa sudo
    emerge -n app-admin/sudo

    ### Shutdown, bisogna essere root.                              -> visudo
    ### Reboot, bisogna essere root (?)                             -> visudo
    ### Service xqueezelite (start,stop,restart) accesso negato.    -> visudo
    ### update-rc.d (autostart) accesso negato                      -> visudo
    if [ -e '/etc/sudoers.d/falcon' ]; then
       rm /etc/sudoers.d/falcon
    fi
    cp /var/www/falcon/falcon/resources/install/gentoo_gallifrey/SystemRoot/etc/sudoers.d/falcon /etc/sudoers.d/falcon
    chown root:root /etc/sudoers.d/falcon 
    chmod 440 /etc/sudoers.d/falcon

}
function install_lighttpd(){

     emerge -n lightpd
     mkdir /var/log/lighttpd
     chown www-data:root /var/log/lighttpd

}
function config_lighttpd(){

    # copia la configurazione del webserver lighttpd
    if [ ! -e '/etc/lighttpd/lighttpd-old.conf' ]; then
        mv /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd-old.conf
    else
        rm /etc/lighttpd/lighttpd.conf
    fi 
    cp /var/www/falcon/falcon/resources/install/WebServer/lighttpd/etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf 
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
else
    install_lighttpd
    config_lighttpd
fi
service lighttpd restart

# END #########################################################################