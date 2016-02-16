
# copia la configurazione del webserver Apache2
mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default-old.conf
cp /var/www/falcon/falcon/resources/install/WebServer/apache2/etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf
#abilita le CGI

ln -s /var/www/falcon/falcon/resources/install/WebServer/apache2/etc/apache2/mods-available/cgid.conf /var/www/falcon/falcon/resources/install/WebServer/apache2/etc/apache2/mods-enabled/cgid.conf
ln -s /var/www/falcon/falcon/resources/install/WebServer/apache2/etc/apache2/mods-available/cgid.load /var/www/falcon/falcon/resources/install/WebServer/apache2/etc/apache2/mods-enabled/cgid.load

