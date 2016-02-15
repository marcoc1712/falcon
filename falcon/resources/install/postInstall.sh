# installa git
cd /var/www
apt-get install git
git clone https://github.com/marcoc1712/falcon.git

# crea la cartella data
cd /var/www/falcon
mkdir data
chown www-data:www-data data

#imposta la configurazione di Falcon
ln -s  /var/www/falcon/falcon/default/conf/debianI386.conf  /var/www/falcon/data/falcon.conf

# ATTENZIONE CONFIGURARE SOLO IL WS effettivamente in uso.

# copia la configurazione del webserver Apache2
mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default-old.conf
cp /var/www/falcon/falcon/resources/install/WebServer/apache2/etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf
#abilita le CGI

ln -s /var/www/falcon/falcon/resources/install/WebServer/apache2/etc/apache2/mods-available/cgid.conf /var/www/falcon/falcon/resources/install/WebServer/apache2/etc/apache2/mods-enabled/cgid.conf
ln -s /var/www/falcon/falcon/resources/install/WebServer/apache2/etc/apache2/mods-available/cgid.load /var/www/falcon/falcon/resources/install/WebServer/apache2/etc/apache2/mods-enabled/cgid.load

# copia la configurazione del webserver lighttpd

mv /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd-old.conf
mv  /var/www/falcon/falcon/resources/install/WebServer/lighttpd/etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf 

#corregge i privilegi di esecuzione agli script:
chmod +x var/www/falcon/cgi-bin/*.pl
chmod +x var/www/falcon/exit/*.pl
chmod +x var/www/falcon/falcon/default/exit/Standard/Linux/Debian_ea/*.pl
chmod +x var/www/falcon/falcon/default/exit/Standard/Linux/*.pl
chmod +x var/www/falcon/falcon/default/exit/myOwn/*.pl

# crea la directory di log ed il file con gli opportuni permessi
mkdir /var/log/falcon
chown www-data:www-data /var/log/falcon
touch /var/log/falcon/falcon.log
chown www-dat:www-data falcon.log
chmod g=rw falcon.log

# aggiunge www-data al gruppo audio, così da vedere tutti i dispositivi.

adduser www-data audio

### adesso carica i settings, ma non salva. qualche problema ancora con command line e status.