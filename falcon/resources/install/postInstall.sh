# installa git
cd /var/www
apt-get install git
git clone https://github.com/marcoc1712/falcon.git

# crea la cartella data
cd /var/www/falcon
mkdir data
chown www-data:www-data data

