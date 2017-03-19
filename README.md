# Falcon

A web interface to Squeezelite (R2).

Install and controll your squeezelite box from any browser in your network, even from your phone.

DISCLAIMER:

This is a pre release tested only for: Debian, Ubuntu and Gentoo, could be easily 
adapted for any other LINUX distribution with minimal effort.

Please contact me if interested in porting Falcon in your distro.

INSTALLATION GUIDE:

Please login to your system as root and download the attached script setup.pl.


Remember to chmod +x setup.pl
then run it ./ setup.pl

use:

--debug  to get some more messages.

--nogit  to not use git to download and install the code (tested only for new clean installs).

--remove to remove falcon instead of install it. 

PLEASE NOTE: 

if --nogit is omitted, will install git client if not already there.

If you have Apache2 or Lighttpd installed, it will use it, otherways it will install Lighttpd and configure it for falcon.

At the end of the installation, if nothing went wrong, you should reach your squeezelite-R2 installation by any browser in your network at the ip address of your player (you could check it in LMS, settings, player).

--remove will remove everything related to falcon from your computer, but not git,the webserver and squeezelite.

Please reports any bugs.

