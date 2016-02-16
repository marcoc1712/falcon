# aggiorna falcon.
cd /var/www/falcon
git pull

# crea la cartella data
cd /var/www/falcon
mkdir data
chown www-data:www-data data

#imposta la configurazione di Falcon
ln -s  /var/www/falcon/falcon/default/conf/debianI386.conf  /var/www/falcon/data/falcon.conf

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
chown www-data:www-data falcon.log
chmod g=rw falcon.log

### adesso carica i settings, ma non salva.

### QUANTO SEGUE E' UN ELENCO DI PROBLEMI E WORK AROUND APPLICATI
### VA CERCATA ED APPLICATA UNA SOLUZIONE MIGLIORE IN FASE DI 
### INSTALLAZIONE CON EASETUP, se mai ci sarà.

### aggiunge www-data al gruppo audio, così da vedere tutti i dispositivi.
adduser www-data audio
### 
### accesso in scrittura a etc/default/squeezelite (ed eventualmente al backup da creare come /etc/default/squeezelite.wbak)
cp /etc/default/squeezelite /etc/default/squeezelite.wbak
chown www-data:www-data /etc/default/squeezelite
chmod g=rw /etc/default/squeezelite

###
### accesso in scrittura al file di log ( ed eventualmente ai files di backup e rotazione,se la si vuole attivare).
mkdir /var/log/squeezelite-R2
chown www-data:www-data  /var/log/squeezelite-R2
touch  /var/log/squeezelite-R2/squeezelite-R2.log
chown www-data:www-data /var/log/squeezelite-R2/squeezelite-R2.log
chmod g=rw /var/log/squeezelite-R2/squeezelite-R2.log
###
### problema (aggirato) dei permessi alla creazione dei nuovi files creati da root nelle cartelle di proprietà www-data
### bisogna impostare umask? a che valore?
###
### Shutdown, bisogna essere root.									-> visudo
### Reboot, bisogna essere root (?)									-> visudo
### Service xqueezelite (start,stop,restart) accesso negato.		-> visudo (?)
### 
### NON FUNZIONA:

### ERROR: from exit: /var/www/falcon/falcon/default/exit/Standard/Linux/Debian_ea/serviceRestart.pl. 
### Message is:   We trust you have received the usual lecture from the local System Administrator. 
### It usually boils down to these three things:  #1) Respect the privacy of others. #2) Think before you type. 
### #3) With great power comes great responsibility.  sudo: no tty present and no askpass program specified

### TODO: Attivare la rotazione dei files di log.
