# Falcon

Falcon. A web interface to Squeezelite (R2).

This is a pre release tested only for: Debian, Ubuntu and Gentoo.

More to come.

INSTALLATION GUIDE:

Please login to your system as root and download the attached script installFalcon[platform].sh.

wget https://github.com/marcoc1712/falcon/releases/download/v.0.1.0/installFalcon_[platform].sh;

Remember to chmod +x installFalconn_[platform].sh.
then run it ./ installFalconn_[platform]sh

PLEASE NOTE: Replace [platform] with one of the supported platform (debian or gentoo at present, where Debian stand also for ubuntu and other derivates) in commands.

If you have Apache2 or Lighttpd installed, it will use it, otherways it will install Lighttpd and configure it for falcon.

At the end of the installation, if nothing went wrong, you should reach your squeezelite-R2 installation by any browser in your network at the ip address of your player (you could check it in LMS, settings, player).

Please reports any bugs.


This is a modified version of squeezelite by Adrian Smith (Triode). 
At the moment of writing (October 2015), original code is here: https://code.google.com/p/squeezelite/, MASTER branch here is a clone.

This version was originally meant to inspect pcm header to detect the real samplerate, depth and endianess, in order to override the wrong information coming from the server when transcoding or upsampling.

October, 4 2015 this feature has been incorporated in Daphile, March,  10 2016 in Audiolinux.

Starting form March, 15 2061 it's included in the squeezebox community official version of squeezelite, mantained by Ralph Irving.

Squeezelite-R2 v1.8.4 now incorporates some functionalities from Daphile: 

1.Launched with -x prevent lms to downsample in case original samplerate is greater than the maximum imposed with -r in command line. 

2.Using ALSA, is now possible to send DSD 'natives' formats (as opposed to DOP) to XMOS based USB interfaces or DACs.
