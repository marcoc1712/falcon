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
###
### Installa chkconfig per l'autostart.
apt-get install chkconfig

### Shutdown, bisogna essere root.									-> visudo
### Reboot, bisogna essere root (?)									-> visudo
### Service xqueezelite (start,stop,restart) accesso negato.		-> visudo
### update-rc.d (autostart) accesso negato							-> visudo

###
### problema (aggirato) dei permessi alla creazione dei nuovi files creati da root nelle cartelle di proprietà www-data
### bisogna impostare umask? a che valore?
###
### TODO: Attivare la rotazione dei files di log.
