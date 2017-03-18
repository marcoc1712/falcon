# Falcon

A web interface to Squeezelite (R2).

Install and controll your squeezelite box from any browser in your network, even from your phone.

DISCLAIMER:

This is a pre release tested only for: Debian, Ubuntu and Gentoo, could be easily 
adapted for any other LINUX distribution with minimal effort.

Please contact me if interested in porting Falcon in your distro.

INSTALLATION GUIDE:

Please login to your system as root and download the attached script installFalcon[platform].sh.

wget https://github.com/marcoc1712/falcon/releases/download/v.0.1.0/installFalcon_[platform].sh;

Remember to chmod +x installFalconn_[platform].sh.
then run it ./ installFalconn_[platform]sh

PLEASE NOTE: Replace [platform] with one of the supported platform (debian or gentoo at present, where Debian stand also for ubuntu and other derivates) in commands.

If you have Apache2 or Lighttpd installed, it will use it, otherways it will install Lighttpd and configure it for falcon.

At the end of the installation, if nothing went wrong, you should reach your squeezelite-R2 installation by any browser in your network at the ip address of your player (you could check it in LMS, settings, player).

Please reports any bugs.

