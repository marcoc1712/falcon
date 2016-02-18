# installa git e falcon.
cd /var/www
apt-get install git
git clone https://github.com/marcoc1712/falcon.git

#corregge i privilegi di esecuzione agli script:
chmod +x /var/www/falcon/cgi-bin/*.pl
chmod +x /var/www/falcon/exit/*.pl
chmod +x /var/www/falcon/falcon/default/exit/Standard/Linux/Debian_ea/*.pl
chmod +x /var/www/falcon/falcon/default/exit/Standard/Linux/*.pl
chmod +x /var/www/falcon/falcon/default/exit/myOwn/*.pl
chmod +x /var/www/falcon/falcon/default/exit/Example/*.pl

# crea la cartella exit
cd /var/www/falcon
mkdir exit
# copia gli script di esempio.
cp var/www/falcon/falcon/default/exit/Examples/*.pl var/www/falcon/exit/*.pl 

# crea la cartella data
cd /var/www/falcon
mkdir data
chown www-data:www-data data

#imposta la configurazione di Falcon
ln -s  /var/www/falcon/falcon/default/conf/debianI386.conf  /var/www/falcon/data/falcon.conf

# crea la directory di log ed il file con gli opportuni permessi
mkdir /var/log/falcon
chown www-data:www-data /var/log/falcon
touch /var/log/falcon/falcon.log
chown www-data:www-data falcon.log
chmod g=rw falcon.log

### adesso carica i settings, ma ancora non salva e molte funzionalità
### non hanno accesso alle risorse necessarie.

### VEDI additionalSettings.sh