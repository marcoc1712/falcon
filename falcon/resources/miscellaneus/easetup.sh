#!/bin/bash
# WARNING: "bashisms"! Not POSIX compliant, do not use a different shell.

##############################################################################
# Easy Audio Setup: semi-automated installation and configuration of
# LMS+Squeezelite audio systems on Debian GNU/Linux OS.
#
# Copyright 2015,2016 Paolo 'UnixMan' Saggese <pms@audiofaidate.org>
# Released under the terms of the GNU General Public License, see:
# http://www.gnu.org/copyleft/gpl.html
##############################################################################
EAS_VERSION=0.15b8
myName=$(basename $0)

# definizione delle funzioni
##############################################################################

function fail() {
  echo -e "\nFatal ERROR: $1\n\nAborted."
  exit $(false)
}

##############################################################################

function pausa() {
  echo
  read -s -p 'Premere "Invio" per continuare...'
  clear
  echo
}

##############################################################################

function run_as_root() {
  [ "$(whoami)" == "root" ] || { 
    echo -e '\a\nATTENZIONE: questo script deve essere eseguito dal "SuperUser" (utente root).'
    exec su -c "$0"
  }
}

##############################################################################

function setup_workdir() {
  # setup della directory di lavoro
  myName=$(basename "$0")
  myWorkdir="/var/tmp/$myName.$(date '+%F.%H-%M-%S')"
  [ ! -e "$myWorkdir" ] && mkdir "$myWorkdir"
  cd "$myWorkdir" || fail "impossibile accedere alla directory di lavoro: $myWorkdir"
}

##############################################################################

function check_for_updates() {
  # memento: eseguire prima di cambiare CWD! (prima di setup_workdir)
  echo
  read -s -N1 -p "Verificare eventuali aggiornamenti di $myName? (S/n)"
  echo
  [ "$REPLY" != "n" ] || return
  echo -e '\nChecking for updates...\n'
  wget "http://www.audiofaidate.org/sw/$myName" -O "./$myName.current" \
    || fail 'Failed to download file.\nPlease check your network connection!'
  [[ -s "./$myName.current" ]] || fail 'Something went wrong: downloaded file empty or unreadable.'
  if ! diff "$0" "./$myName.current" > /dev/null
  then
    echo -e '\nUpdated version found!\n'
    [ -f "./$myName" ] && mv -vf "./$myName" "./$myName.bak"
    mv -vf "./$myName.current" "./$myName"
    chmod +x "./$myName"
    echo -e '\nRestarting new script.'
    pausa
    exec "./$myName"
  else
    echo -e '\nOK, the script is up to date.\n'
  fi
}

##############################################################################

function check_debian_version() {
  echo -e '\nVerifica del Sistema Operativo...\n'
  if [ ! -f /etc/debian_version ] || egrep -qv '^8\.' /etc/debian_version ; then
  cat <<-EWARN1
	ATTENZIONE: è stato rilevato un sistema diverso da Debian 8.x "Jessie".
  
	Questo script è pensato esclusivamente per Debian 8.x "Jessie" e sistemi
	derivati e perfettamente compatibili con questo (come ad es. LMDE 2).
	Il suo utilizzo con versioni o distribuzioni diverse non è supportato e
	potrebbe danneggiare il vostro sistema.

	EWARN1
    read -s -N1 -p 'Procedere comunque? (s/n)'
    echo
    if [ "$REPLY" != "s" ]; then
      echo -e '\nAbort.\n'
      exit 1
    else
      echo -e "\nOK, good luck. You've been warned...\n"
    fi
  fi
}

##############################################################################

function select_install_type() {
  # selezione del tipo di sistema da installare
  TipoSistema=""
  clear
  while [ "$TipoSistema" == "" ] ; do
    cat <<-ECHOICE

	Cosa si desidera installare?

	  0) nulla, solo setup di base
	  1) sistema player (squeezelite)
	  2) systema server (LMS)
	  3) sistema completo stand-alone, server+player (LMS+squeezelite)

	ECHOICE
    read -N1 -p 'Digitare il numero corrispondente (0|1|2|3): ' SceltaSistema
    echo
    case "$SceltaSistema" in
      0)
	  TipoSistema="custom"
	  ;;
      1)
	  TipoSistema="player"
	  ;;
      2)
	  TipoSistema="server"
	  ;;
      3)
	  TipoSistema="completo"
	  ;;
      *)
	  clear
	  echo -e "\a\nErrore: selezione non prevista.\nSi prega di digitare un numero compreso tra 0 e 3.\n"
    esac
    if [ "$TipoSistema" != "" ]; then
      echo -e "\nScelta effettuata: sistema $TipoSistema\n"
      read -s -N1 -p 'Confermare e procedere con l´installazione? (s/N)'
      clear
      echo
      [ "$REPLY" != "s" ] && TipoSistema=""
    fi
  done
}

##############################################################################

function udev_setup() {
  echo -e '\nConfigurazione di "udev"...\n'
  [ -f /etc/udev/rules.d/40-timer-permissions.rules ] && mv -f /etc/udev/rules.d/40-timer-permissions.rules /etc/udev/rules.d/40-timer-permissions.rules.bak
  cat <<-EOHPT > /etc/udev/rules.d/40-timer-permissions.rules 
	KERNEL=="rtc0", GROUP="audio"
	KERNEL=="hpet", GROUP="audio"
	EOHPT
  # Attivazione immediata delle modifiche precedenti:
  service udev force-reload
  chgrp audio /dev/hpet /dev/rtc0
  chmod 660 /dev/hpet /dev/rtc0
}

##############################################################################

function sysctl_setup() {
  echo
  read -s -N1 -p 'Configurare i parametri del Kernel (via sysctl)? (S/n)'
  echo
  [ "$REPLY" != "n" ] || return
  [ -f /etc/sysctl.d/60-max-user-freq.conf ] && mv -f /etc/sysctl.d/60-max-user-freq.conf /etc/sysctl.d/60-max-user-freq.conf.bak
  [ -f /etc/sysctl.d/99-local.conf ] && mv -f /etc/sysctl.d/99-local.conf /etc/sysctl.d/99-local.conf.bak
  cat <<-EOSC > /etc/sysctl.d/99-local.conf
	# Configuration file for runtime kernel parameters.
	# See sysctl.conf(5) for more information.

	# vm.swappiness = 60 # default
	vm.swappiness = 10

	# Contains, as a percentage of total system memory, the number of pages at which
	# a process which is generating disk writes will start writing out dirty data.
	## Arch default = 10.
	vm.dirty_ratio = 3

	# Contains, as a percentage of total system memory, the number of pages at which
	# the background kernel flusher threads will start writing out dirty data.
	## Arch default = 5.
	vm.dirty_background_ratio = 2

	kernel.perf_cpu_time_max_percent = 50
	kernel.perf_event_max_sample_rate = 50000

	# Protection from the SYN flood attack.
	net.ipv4.tcp_syncookies = 1

	# Disable packet forwarding.
	net.ipv4.ip_forward = 0
	net.ipv6.conf.all.forwarding = 0
	
	fs.inotify.max_user_watches = 524288

	# set high precision timer
	dev.hpet.max-user-freq=3072

	# ATTENZIONE: impostazioni sperimentali! 
	kernel.sched_latency_ns = 6000000
	kernel.sched_migration_cost_ns = 7000000
	kernel.sched_min_granularity_ns = 100000
	kernel.sched_nr_migrate = 8
	kernel.sched_rr_timeslice_ms = 25
	kernel.sched_rt_period_us = 1000000 
	kernel.sched_rt_runtime_us = 970000
	kernel.sched_shares_window_ns = 80000
	kernel.sched_time_avg_ms = 1000
	kernel.sched_tunable_scaling = 1
	kernel.sched_wakeup_granularity_ns = 10000
	# Se notate problemi strani, provate a commentare le righe precedenti.

	# ATTENZIONE:
	# Le seguenti variabili consentono di modificare le impostazioni dello stack 
	# TCP/IP. I valori di default (che non sono quelli qui indicati) rappresentano 
	# un buon compromesso che va bene nella maggior parte dei casi.
	# Modificare tali impostazioni può consentire l'ottimizzazione di determinate 
	# prestazioni (a discapito di altre) in funzione delle esigenze specifiche delle 
	# proprie applicazioni, ma la loro impostazione a valori "sbagliati" o comunque
	# non adeguati alle esigenze del caso possono facilmente produrre un sensibile 
	# peggioramento delle prestazioni rispetto ai valori default e, in alcuni casi,
	# perfino causare malfunzionamenti dei servizi di rete. Usare con cautela!
	
	# Set the max OS send buffer size (wmem) and receive buffer size (rmem) to 12MB
	# for queues on all protocols. In other words set the amount of memory that is
	# allocated for each TCP socket when it is opened or created while transferring
	# files:
	#net.core.wmem_max=12582912
	#net.core.rmem_max=12582912
	#
	# You also need to set minimum size, initial size, and maximum size in bytes:
	#net.ipv4.tcp_rmem= 10240 87380 12582912
	#net.ipv4.tcp_wmem= 10240 87380 12582912

	# Turn on window scaling which can be an option to enlarge the transfer window:
	#net.ipv4.tcp_window_scaling = 1

	# Enable timestamps as defined in RFC1323:
	#net.ipv4.tcp_timestamps = 1

	# Enable select acknowledgments:
	#net.ipv4.tcp_sack = 1

	# By default, TCP saves various connection metrics in the route cache when the
	# connection closes, so that connections established in the near future can use
	# these to set initial conditions. Usually, this increases overall performance,
	# but may sometimes cause performance degradation. If set, TCP will not cache
	# metrics on closing connections.
	#net.ipv4.tcp_no_metrics_save = 1

	# Set maximum number of packets, queued on the INPUT side, when the interface
	# receives packets faster than kernel can process them.
	#net.core.netdev_max_backlog = 5000	
	
	EOSC
  # Attivazione immediata delle modifiche precedenti:
  sysctl -q -p /etc/sysctl.d/99-local.conf
}

##############################################################################

function limits_setup() {
  echo -e '\nSetup di limiti e permessi di sistema per il gruppo "audio"...'
  [ -f /etc/security/limits.d/audio.conf ] && mv -f /etc/security/limits.d/audio.conf /etc/security/limits.d/audio.conf.bak
  cat <<-EOAL > /etc/security/limits.d/audio.conf
	# limits for users/processes in audio grup

	#@audio - rtprio 99
	@audio - rtprio 95
	@audio - nice -15
	#@audio - memlock unlimited
	#@audio - memlock 250000
	@audio - memlock 500000

	EOAL
}

##############################################################################

function rclocal_setup() {
  echo
  read -s -N1 -p 'Modificare il file /etc/rc.local (avvio automatico)? (S/n)'
  echo
  [ "$REPLY" != "n" ] || return
  echo -e '\n'
  [ -f /etc/rc.local ] && mv -f /etc/rc.local /etc/rc.local.bak
  cat <<-EORL > /etc/rc.local
	#!/bin/sh -e
	#
	# rc.local
	#
	# This script is executed at the end of each multiuser runlevel.
	# Make sure that the script will "exit 0" on success or any other
	# value on error.
	#
	# In order to enable or disable this script just change the execution
	# bits.

	echo 3072 > /sys/class/rtc/rtc0/max_user_freq

	exit 0
	EORL
  chmod +x /etc/rc.local
  # Attivazione immediata della modifica precedente:
  echo 3072 > /sys/class/rtc/rtc0/max_user_freq
}

##############################################################################

function grub_setup() {
  echo
  read -s -N1 -p 'Modificare le opzioni di avvio (setup di "grub")? (S/n)'
  echo
  [ "$REPLY" != "n" ] || return
  echo -e "\nConfigurazione del boot manager 'grub'..."
  if ! grep -E -s -q '^\s?+GRUB_SAVEDEFAULT' /etc/default/grub ; then
    # GRUB_SAVEDEFAULT non è definito
    if grep -E -s -q '^\s?+GRUB_DEFAULT' /etc/default/grub ; then
      sed -r -i 's/^\s?+GRUB_DEFAULT.*$/GRUB_SAVEDEFAULT=true\nGRUB_DEFAULT=saved/' /etc/default/grub
    else
      echo -e '\n\nGRUB_SAVEDEFAULT=true\nGRUB_DEFAULT=saved\n' >> /etc/default/grub
    fi
  else
    # GRUB_SAVEDEFAULT è già definito
    if grep -E -s -q '^\s?+GRUB_DEFAULT' /etc/default/grub ; then
      sed -r -i 's/^\s?+GRUB_DEFAULT.*$/GRUB_DEFAULT=saved/'		/etc/default/grub
      sed -r -i 's/^\s?+GRUB_SAVEDEFAULT.*$/GRUB_SAVEDEFAULT=true/'	/etc/default/grub
    else
      sed -r -i 's/^\s?+GRUB_SAVEDEFAULT.*$/GRUB_SAVEDEFAULT=true\nGRUB_DEFAULT=saved/' /etc/default/grub
    fi
  fi
  echo -e '\nAggiunta di "threadirqs" ai parametri di avvio del Kernel'
  sed -r -i.bak '/threadirqs/!{s/^(GRUB_CMDLINE_LINUX.*)\"(.*)\"/\1"\2 threadirqs"/};s/=" /="/' /etc/default/grub
  echo -e '\nApplicazione delle modifiche...'
  if update-grub >> "grub.log" 2>&1 ; then
    echo -e "\nSetup del boot manager completato.\n"
  else
    cat <<-EOGW

	ATTENZIONE:
	Il comando "update-grub" è fallito: il sistema potrebbe non riavviarsi.
	
	Prima di arrestare o riavviare il sistema, si raccomanda di verificare
	il contenuto del file di configurazione, ad es.:
	
	  nano /etc/default/grub
	
	e quindi eseguire nuovamente il comando update-grub.
	
	EOGW
    pausa
  fi
}

##############################################################################

function fstab_setup() {
  echo
  read -s -N1 -p 'Aggiungere "noatime" alle opzioni di mount dei file system? (S/n)'
  echo
  if [ "$REPLY" != "n" ]; then
    sed -r -i.bak '/atime/!{s/(ext.\s+)(\w+)/\1noatime,\2/}' /etc/fstab
  fi
}

##############################################################################

function disable_swap() {
  clear
  cat <<-EOSW

	Per i sistemi solo "player" (squeezelite) lo "swap" (memoria virtuale
	su disco, AKA "area di scambio") è superfluo. Dato che potrebbe anche
	interferire con la riproduzione, se ne sconsiglia l'uso.
	
	Se il sistema dispone di una quantità sufficiente di RAM fisica, non è
	necessario utilizzarlo neanche per sistemi che includono il server LMS.
	
	Qualora inoltre il disco su cui risiede la partizione di swap sia in
	effetti una memoria a stato solido ("flash": SSD, CF, SD, USB memory-
	sticks, ecc), le frequenti operazioni di scrittura tipiche dello swap
	portano ad un precoce deterioramento della stessa.
	In tali casi è pertanto sempre decisamente sconsigliato utilizzare lo
	swap su disco.
	
	EOSW
  read -s -N1 -p 'Disabilitare lo swap su disco? (S/n)'
  echo
  if [ "$REPLY" != "n" ]; then
    echo -e '\nDisabilitazione dello swap.'
    swapoff -a
    sed -i -r '/swap/{s/^([^#].*)$/#\1/}' /etc/fstab
  fi
}

##############################################################################

function uninstall_syslogger() {
  clear
  cat <<-EOSW

	Normalmente i sistemi Linux utilizzano un servizio di memorizzazione
	su disco dei log (AKA "registri") di sistema (syslog). Laddove non sia
	necessario tenere traccia (semi)permanente di tali informazioni, tale
	servizio può essere disinstallato.
	
	Nelle applicazioni "real-time" questo può essere vantaggioso in quanto
	elimina un processo attivo e riduce gli accessi al disco superflui.
	
	È inoltre raccomandata la sua disinstallazione laddove il disco su cui
	risiede il file-system "/var" sia in effetti una memoria a stato solido
	("flash": SSD, CF, SD, USB memory-sticks, ecc), in quanto le frequenti
	operazioni di scrittura dei log files possono portare ad un precoce
	deterioramento della stessa.
	
	EOSW
  read -s -N1 -p 'Disinstallare il syslogger? (S/n)'
  echo
  if [ "$REPLY" != "n" ]; then
    echo -e '\nDisinstallazione di syslog...'
    apt-get -y purge '^(.|busybox-)?syslog(d)?(-ng.*)?$' >> "purge.syslog.log" 2>&1
  fi
}

##############################################################################

function apt_update() {
  echo -e '\nAggiornamento delle liste dei pacchetti...'
  apt-get update 2>&1 | tee -a "update.log"
  echo -e '\nInstallazione dei "keyrings" per APT...'
  apt-get --allow-unauthenticated -y install '((^(deb(ian)?|liquorix)-([^-]+-)?)|-archive-)keyring.?'
  pausa
  echo -e '\nÈ necessario aggiornare di nuovo...'
  apt-get update
  pausa
}

##############################################################################

function base_repos_setup() {
  echo -e '\nAggiunta dei repository di base + multimedia, inclusi "non-free" e "contrib"'
  [ -f /etc/apt/sources.list ] && mv -f /etc/apt/sources.list /etc/apt/sources.list.bak
  [ -f /etc/apt/sources.list.d/debian.list ] && mv -f /etc/apt/sources.list.d/debian.list /etc/apt/sources.list.d/debian.list.bak
  cat <<-EOD > /etc/apt/sources.list.d/debian.list

	#deb http://httpredir.debian.org/debian jessie main contrib non-free
	#deb http://httpredir.debian.org/debian jessie-updates main contrib non-free

	deb http://ftp.debian.org/debian jessie main contrib non-free
	deb http://ftp.debian.org/debian jessie-updates main contrib non-free

	#deb http://ftp.debian.org/debian jessie-backports main non-free contrib
	#deb http://ftp.debian.org/debian jessie-backports-sloppy main non-free contrib

	deb http://security.debian.org/ jessie/updates main contrib non-free

	deb http://www.deb-multimedia.org jessie main non-free

	EOD
  apt_update
}

##############################################################################

function liquorix_repos_setup() {
  echo -e '\nAggiunta del repository del kernel "Liquorix"'
  [ -f /etc/apt/sources.list.d/liquorix.list ] && mv -f /etc/apt/sources.list.d/liquorix.list /etc/apt/sources.list.d/liquorix.list.bak
  cat <<-EOLS > /etc/apt/sources.list.d/liquorix.list
	# Liquorix is a distro kernel replacement built using the best
	# configuration and kernel sources for desktop, multimedia, and 
	# gaming workloads.

	deb http://liquorix.net/debian sid main past
	#deb-src http://liquorix.net/debian sid main past

	# Mirrors:
	# Unit193 - France
	# deb http://mirror.unit193.net/liquorix sid main
	# deb-src http://mirror.unit193.net/liquorix sid main
	# Liquorix - Cloudfront Global CDN
	# deb http://cdn.liquorix.net/debian sid main
	# deb-src http://cdn.liquorix.net/debian sid main

	EOLS
  apt_update
}

##############################################################################

function basic_packages_setup() {
  echo
  read -s -N1 -p 'Aggiornare il sistema? (S/n)'
  echo
  if [ "$REPLY" != "n" ] 
  then 
  base_repos_setup
  echo -e '\nInstallazione degli aggiornamenti di sistema...'
    apt-get -y dist-upgrade 2>&1 | tee -a "upgrade.log"
    echo -e '\nRimozione dei pacchetti superflui...'
    apt-get -y autoremove 2>&1 | tee -a "autoremove.log" 
  fi
  echo -e '\nInstallazione accessori vari, ALSA utils, rtirq, ffmpeg, sox, ecc...'
  package_list="\
	alsa-utils		\
	aptitude		\
	apt-transport-https	\
	fdupes			\
	ffmpeg			\
	firmware-linux		\
	firmware-linux-free	\
	firmware-linux-nonfree	\
	flac			\
	gawk			\
	gdebi-core		\
	gpm			\
	htop			\
	libsox-fmt-all		\
	mc			\
	openssh-client		\
	openssh-server		\
	rtirq-init		\
	schedtool		\
	sox			\
	sysvinit-utils		\
	ssh			\
	sudo			\
	unzip			\
	util-linux		\
  "
  apt-get --install-recommends -y install $package_list 2>&1 | tee -a "install.packages.log"
  echo -e '\nDownload ed installazione di "alsa-info.sh"...'
  wget http://www.alsa-project.org/alsa-info.sh -O /usr/local/bin/alsa-info.sh \
  && chmod +x /usr/local/bin/alsa-info.sh
  pausa
}

##############################################################################

function install_liquorix_kernel() {
  clear
  cat <<-EOKW
	Liquorix è un sostituto dei kernel standard forniti dalle distribuzioni,
	costruito utilizzando le migliori configurazioni ed i migliori sorgenti
	per impieghi di tipo desktop, multimedia e videogiochi.
	Le caratteristiche di tali Kernel possono avere effetti benefici anche
	sulla qualità della riproduzione audio.
	Per contro si tratta di Kernel molto "freschi" (==> poco testati) e con
	configurazioni piuttosto estreme; pertanto tipicamente sono meno stabili
	ed affidabili di quelli di default.
	Inoltre, poiché vengono rilasciati per Debian "Sid" (unstable), non sono
	pienamente compatibili con la versione stabile. In particolare non è
	possibile installare su una "stable" i corrispondenti "headers" e quindi
	non è possibile compilare eventuali moduli aggiuntivi.
	ATTENZIONE:
	se state effettuando una installazione di prova su un sistema 'Live' non
	tentate di installare un nuovo Kernel.
	
	EOKW
  read -s -N1 -p 'Installare il Kernel "Liquorix"? (S/n)'
  echo
  if [ "$REPLY" != "n" ]; then
    liquorix_repos_setup
    echo -e '\nInstallazione del Kernel Liquorix...'
    if [ "$(arch)" == "x86_64" ]; then
      MyKernel="linux-image-liquorix-amd64"
    else
      MyKernel="linux-image-liquorix-686"
    fi
    #apt-get --no-install-recommends -y install $MyKernel 2>&1 | tee -a "install.kernel.log"
    apt-get --no-install-recommends install $MyKernel
    cat <<-EOK
	ATTENZIONE: 
	per attivare il nuovo Kernel sarà necessario riavviare il sistema.
	EOK
    pausa
  fi
}

##############################################################################

function run_alsamixer() {
  # esegue alsamixer per la verifica delle impostazioni
  clear
  echo
  cat <<-EOAMIX | less
	(utilizzate i tasti freccia e PgUp/PgDn per far scorrere il testo. 
	Premete il tasto "q" per uscire da questo visualizzatore).

	Verrà ora avviato "alsamixer", una interfaccia al "mixer" di ALSA.
	
	Verificate che le impostazioni del dispositivo di uscita audio siano
	corrette; in modo particolare controllate che i volumi non siano posti
	a zero e che la/e uscita/e non siano in mute (non deve essere presente 
	una "M" sotto la barra del volume). Utilizzate:
	
	* il tasto "F6" per scegliere il dispositivo di uscita su cui agire
	 (quello che avete scelto è preselezionato);
	
	* i tasti "freccia" destra/sinistra per spostarvi tra i cursorsi;
	
	* i tasti "freccia" su/giù per cambiare il valore dei cursori;
	
	* il tasto 'm' per attivare/disattivare il "mute";
	
	* il tasto "Esc" per uscire da alsamixer.
	
	EOAMIX
  alsamixer $(test -v myCDev && echo "-c $myCard")
}

##############################################################################

function test_output_dev() {
  while true
  do
    clear
    cat <<-EOTDEV1
	
	Si procederà ora con un rapido test del dispositivo di uscita che 
	avete scelto, per verificarne la funzionalità.
	Per prima cosa verrà avviato il mixer e vi verrà chiesto di verificare
	le impostazioni del dispositivo di uscita, quindi verrà riprodotto un 
	breve messaggio e vi verrà chiesto di confermare se è stato riprodotto 
	correttamente. 
	Assicuratevi perciò che il sistema audio sia acceso e funzionante, che
	sia selezionato l'ingresso appropriato, che i volumi siano regolati in
	modo opportuno, ecc.
	EOTDEV1
    pausa
    run_alsamixer
    if ! AUDIODEV=$myOutputDev play /usr/share/sounds/alsa/Front_Center.wav
    then
      cat <<-EOTDEV2
	
	ATTENZIONE: 
	si è verificato un errore: il tentativo di riprodurre un breve file
	audio attraverso il dispositivo selezionato è fallito.

	Questo potrebbe indicare che avete scelto il dispositivo sbagliato,
	oppure che questo non sta funzionando correttamente.
	EOTDEV2
      pausa
      return $(false)
    else
      echo
      read -s -N1 -p 'Il messaggio è stato riprodotto correttamente? (s/N)'
      clear
      [ "$REPLY" == "s" ] && return $(true)
      cat <<-EOTDEV3
	
	Se non avete udito il breve messaggio riprodotto per prima cosa 
	verificate il sistema audio, i collegamenti, i livelli di uscita,
	ecc. Se tutto è a posto, è possibile che non abbiate selezionato
	il dispositivo di uscita corretto, oppure che per qualche motivo 
	questo non sta funzionando correttamente.
	EOTDEV3
      echo
      read -s -N1 -p 'Ripetere il test? (S/n)'
      echo
      [ "$REPLY" == "n" ] && return $(false)
    fi
  done
}

##############################################################################

function select_outupt_dev() {
  # verifica della disponibilità e selezione del dispositivo di uscita
  myCard=""
  while [ "$myCard" == "" ]
  do
    clear
    IFS=$'\n'
    outDev=($(aplay -l |awk '/^card / { print $0 }') "Il mio dispositivo non è nell'elenco")
    unset IFS
    maxCardNum=$[ ${#outDev[@]}-1 ]
    if [ $maxCardNum -le 0 ]
    then
      echo -e '\n\a\nATTENZIONE: il sistema non ha riconosciuto nessuna interfaccia audio!\n'
      pausa
      myCard=-1 # fake
    else
      echo -e '\nElenco dei dispositivi di uscita audio riconosciuti dal sistema;\nselezionare il dispositivo di uscita che si intende utilizzare:\n'
      for (( i = 0 ; i < ${#outDev[@]} ; i++ ))
      do
	echo -e "$i) \t${outDev[$i]}";
      done
      echo
      read -p 'Digitare il numero corrispondente e premere invio: ' SceltaDispositivo
      echo
      if [[ "$SceltaDispositivo" =~ ^[0-9]+$ ]] && [ "$SceltaDispositivo" -lt $maxCardNum ]
      then
	myCard=$(echo "${outDev[$SceltaDispositivo]}" |sed -r 's/card\s+([0-9]+).*/\1/')
	myCDev=$(echo "${outDev[$SceltaDispositivo]}" |sed -r 's/.*device\s+([0-9]+).*/\1/')
	echo -e "Scelta effettuata: '$(echo ${outDev[$SceltaDispositivo]})' (hw:$myCard,$myCDev)\n"
	read -s -N1 -p 'Confermare e procedere? (s/N)'
	if [ "$REPLY" == "s" ]
	then
	  myCardName=$(cat /proc/asound/card$myCard/id)
	  myOutputDev="hw:CARD=$myCardName,DEV=$myCDev"
	  test_output_dev || myCard=""
	else
	  myCard=""
	fi
      elif [[ "$SceltaDispositivo" =~ ^[0-9]+$ ]] && [ "$SceltaDispositivo" -eq $maxCardNum ]
      then
	myCard=-1
      else
	echo -e "\a\nErrore: digitare un numero compreso tra 0 e $maxCardNum."
	pausa
      fi
    fi
    if [ $myCard != "" ] && [ $myCard -lt 0 ]
    then
      cat <<-AUDIOHWM | less
	(utilizzate i tasti freccia e PgUp/PgDn per far scorrere il testo.
	Premete il tasto "q" per uscire da questo visualizzatore).
	
	Se il dispositivo di uscita audio che volete utilizzare non è stato
	riconosciuto dal sistema, per prima cosa verificate che sia acceso e
	sia collegato correttamente.

	ATTENZIONE: alcuni dispositivi possono richiedere che venga seguita una
	precisa sequenza di accensione e/o di collegamento. Se questa non viene
	rispettata l'interfaccia potrebbe non funzionare correttamente e/o non
	essere riconosciuta affatto dal sistema.
	
	Purtroppo tale (eventuale) sequenza cambia da un dispositivo all'altro:
	non esiste una regola generale valida per tutti.
	Ad es. alcuni dispositivi devono essere accesi prima di essere collegati
	al computer, mentre per altri è vero il contrario - devono essere accesi
	solo dopo che sono stati collegati.
	È Inoltre possibile che in alcuni casi il dispositivo debba essere acceso
	e/o collegato solo dopo che il sistema ha completato la sequenza di avvio,
	mentre in altri può essere vero il contrario (il dispositivo deve essere
	collegato ed acceso prima dell'avvio, a computer spento), ecc.
	
	Si consiglia di effettuare subito tutte le verifiche necessarie; qualora
	sia necessario riavviare il sistema, una volta completata la sequenza di
	avvio dovrete riavviare manualmente questo script per poter completare la
	configurazione.

	Se nonostante tutto il vostro dispositivo non dovesse essere riconosciuto,
	è possibile che non sia supportato dal kernel in esecuzione.
	
	In alcuni casi il problema può essere risolto banalmente utilizzando una
	versione più recente del kernel, che contiene driver ALSA più aggiornati:
	provate quindi a riavviare il sistema con un kernel più recente, quindi
	avviate nuovamente questo script.
	
	In altri casi potrebbe essere necessario installare dei "driver" (moduli
	del kernel) aggiuntivi, non inclusi direttamente nel kernel ma forniti
	separatamente dal produttore dell'hardware o da terze parti.
	In tal caso purtroppo non è possibile gestire la cosa in modo automatico
	e dovrete quindi intervenire manualmente.
	Ciò fatto potrete però eseguire nuovamente questo script per completare
	la configurazione.
	
	Infine esistono purtroppo alcuni dispositivi che, per scelta dei loro
	stessi produttori, non sono e non possono essere supportati da sistemi
	diversi da quelli previsti (di solito determinate versioni di Windows
	e/o di MacOS). In tal caso c'è ben poco da fare... se non liberarvene
	e sostituirli con altri che funzionino bene con Linux.

	(utilizzate i tasti freccia e PgUp/PgDn per far scorrere il testo. Premete
	il tasto "q" per uscire da questo visualizzatore).
	
	AUDIOHWM
    clear
    echo
    read -s -N1 -p 'Verificare nuovamente se l´interfaccia è stata riconosciuta? (S/n)'
    echo
    if [ "$REPLY" != "n" ]; then
      myCard=""
    else
      cat <<-AUDIOHW3
	
	Potete scegliere se procedere con l´installazione del solo setup di base,
	quindi riavviare il sistema ed avviare nuovamente lo script per ritentare
	il riconoscimento del dispositivo di uscita audio con il nuovo kernel o
	terminare qui la procedura automatica.

	AUDIOHW3
      read -s -N1 -p 'Procedere con l´installazione del solo setup di base? (s/N)'
      echo
      if [ "$REPLY" == "s" ]; then
	TipoSistema="custom"
      else
	echo -e '\nProcedura abortita come richiesto. Bye.\n'
	exit 1
      fi
    fi
  fi
  done
}

##############################################################################

function select_bit_depth() {
  # selezione del bit-depth supportato dal dispositivo di uscita
  declare -a depths=(	\
	'16'		\
	'24'		\
	'32'		\
  )
  bit_depth=""
  while [ "$bit_depth" == "" ]
  do
  clear
  cat <<-EOBR
	
	Si dovrà ora procedere a selezionare la "profondità di quantizzazione"
	(massima) supportata dal vostro dispositivo di uscita audio (espressa
	come numero di bit, anche nota come "bit depth").
	
	ATTENZIONE:
	selezionare un valore errato o non supportato può impedire il corretto
	funzionamento del sistema o causare degradazione delle sue prestazioni
	in termini di qualità dell'audio.
	EOBR
    echo -e "\nSelezionare il "bit-depth" supportato dal dispositivo di uscita:\n"
    for (( i = 0 ; i < ${#depths[@]} ; i++ ))
    do
      echo -e "$i) \t${depths[$i]}";
    done
    echo
    read -p 'Digitare il numero corrispondente e premere invio: ' choice
    echo
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -lt ${#depths[@]} ]; then
      bit_depth="${depths[$choice]}"
      echo -e "Scelta effettuata: '$bit_depth'\n"
      read -s -N1 -p 'Confermare e procedere? (s/N)'
      clear
      echo
      [ "$REPLY" != "s" ] && bit_depth=""
    else
      echo -e "\a\nErrore: digitare un numero compreso tra 0 e $[ ${#depths[@]}-1 ]."
      pausa
    fi
  done
}

##############################################################################

function select_sample_rate() {
  declare -a rates=(	\
	'44100'		\
	'48000'		\
	'88200'		\
	'96000'		\
	'176400'	\
	'192000'	\
	'352800'	\
	'384000'	\
  )
  # no existing hardware support for '705600' and '768000'.
  if [ "$1" == "" ]; then 
    local prompt='Selezionare un sample rate:'
  else
    local prompt="$1"
  fi
  sample_rate=""
  while [ "$sample_rate" == "" ]
  do
    clear
    echo -e "\n$prompt\n"
    for (( i = 0 ; i < ${#rates[@]} ; i++ ))
    do
      echo -e "$i) \t${rates[$i]}";
    done
    echo
    read -p 'Digitare il numero corrispondente e premere invio: ' choice
    echo
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -lt ${#rates[@]} ]; then
      sample_rate="${rates[$choice]}"
      echo -e "Scelta effettuata: '$sample_rate'\n"
      read -s -N1 -p 'Confermare e procedere? (s/N)'
      clear
      echo
      [ "$REPLY" != "s" ] && sample_rate=""
    else
      echo -e "\a\nErrore: digitare un numero compreso tra 0 e $[ ${#rates[@]}-1 ]."
      pausa
    fi
  done
}

##############################################################################

function select_sample_rate_range() {
  # selezione dei sample-rate supportati dal dispositivo di uscita
  #
  ratesRange=""
  while [ "$ratesRange" == "" ]
  do
  clear
  cat <<-EOSRR | less
  
	(utilizzate i tasti freccia e PgUp/PgDn per far scorrere il testo. 
	Premete il tasto "q" per uscire da questo visualizzatore).
	
	Si dovrà ora procedere a selezionare le frequenze di campionamento dei
	flussi audio digitali ("sample-rate") che sono direttamente supportate
	dal vostro dispositivo di uscita audio.
	
	Vanno indicati i limiti effettivi del sistema nel suo complesso: qualora
	si utilizzi un sistema composto da interfaccia+DAC separati, ciascuno con
	i suoi propri limiti, i valori da indicare sono dati dal sottoinsieme dei
	sample-rate supportati sia dall'interfaccia che dal DAC.
	
	Ad es., se avete una interfaccia USB che supporta tutti i sample-rate a
	partire da 44.1 fino a 384 kHz, ma il DAC che c'è collegato arriva solo
	fino a 192 kHz, il limite max da specificare è 192 kHz.
	Se invece alla stessa interfaccia è collegato un DAC capace di arrivare
	fino a 768 kHz, il limite sarebbe posto dall'interfaccia. Perciò in tal
	caso il valore max da specificare sarebbe 384 kHz.
	
	Se avete qualche motivo particolare per volerlo fare, nulla vieta di
	specificare dei limiti più restrittivi rispetto a quelli imposti dal
	vostro hardware. Ad es., se il vostro sistema è in grado di gestire
	flussi fino a 384 kHz ma funziona/suona meglio fino a 192 kHz, nulla
	vieta di impostare tale valore come limite superiore.
	
	Ovviamente il contrario non è vero: impostare i limiti a valori che
	eccedano il massimo e/o siano inferiori al minimo consentito dal vostro
	hardware è un errore che porta al mancato funzionamento del sistema.

	N.B.: a prescindere dai limiti impostati, il sistema sarà comunque in
	grado di gestire flussi audio in ingresso con qualsiasi sample rate che
	sia supportato dal software (LMS e squeezelite). Se questi eccedono i
	limiti fisici del vostro hardware o comunque quelli impostati qui, il
	software provvederà automaticamente a ricampionare tali flussi in modo
	da renderli compatibili (farli rientrare nei limiti).
	
	In effetti, un possibile motivo per voler impostare dei limiti più
	restrittivi rispetto a quanto consentito dall'hardware è proprio quello
	di "forzare" il ricampionamento dei flussi audio in ingresso.
	
	Ad es., se il vostro hardware supporta flussi audio fino a 96 kHz ed
	impostate proprio tale valore sia come limite inferiore che superiore,
	il risultato sarà che tutti i flussi in ingresso saranno ricampionati
	proprio a tale frequenza (verrà effettuato un "upsampling" oppure un
	"downsampling", a seconda che il flusso in ingresso abbia frequenza
	di campionamento minore o maggiore di quella richiesta).
	
	Un'altra possibilità utilizzata comunemente è quella di impostare il
	limite inferiore e superiore alle frequenze corrispondenti ai massimi
	multipli interi supportati dall'hardware delle due frequenze "base",
	44.1 e 48 kHz, ad es. 176.4 e 192 kHz, oppure 352.8 e 384 kHz, ecc.
	
	In questo modo è possibile ottenere un "ricampionamento sincrono" dei
	flussi in ingresso, cioè far sì che questi vengano sempre ricampionati
	al massimo multiplo intero (supportato) della loro frequenza base.
	
	Se invece volete (per quanto possibile) evitare il ricampionamento
	(almeno sul "player"), indicate correttamente gli effettivi limiti
	minimo e massimo imposti dal vostro hardware.
	
	(utilizzate i tasti freccia e PgUp/PgDn per far scorrere il testo.
	Premete il tasto "q" per uscire da questo visualizzatore).
	
	EOSRR
    clear
    select_sample_rate 'Selezionare la MASSIMA frequenza di campionamento supportata:'
    maxRate=$sample_rate
    select_sample_rate 'Selezionare la MINIMA frequenza di campionamento supportata:'
    minRate=$sample_rate
    if [ $maxRate -eq $minRate ]; then
      ratesRange="$minRate"
    elif [ $maxRate -lt $minRate ]; then
      ratesRange="$maxRate-$minRate"
    else
      ratesRange="$minRate-$maxRate"
    fi
    echo -e "\nRange di frequenze di campionamento selezionato: '$ratesRange'\n"
    read -s -N1 -p 'Confermare e procedere? (s/N)'
    clear
    echo
    [ "$REPLY" != "s" ] && ratesRange=""
  done
}

##############################################################################

function purge_pulseaudio() {
  clear
  cat <<-EOPPA

	PulseAudio (precedentemente noto come PolypAudio) è un sofisticato
	server audio multipiattaforma, che ha il compito di gestire in modo
	semplice ed efficace i diversi flussi audio in ingresso ed uscita.
	Per le nostre applicazioni risulta però di intralcio in quanto, se
	è in esecuzione, monopolizza tutte le interfacce audio presenti nel
	sistema e permette di accedervi solo attraverso di sé. Salvo casi
	ed esigenze particolari si raccomanda pertanto di disinstallarlo.
	In caso contrario sarà necessario procedere ad una appropriata
	configurazione tanto di PA che di squeezelite in modo manuale.
	ATTENZIONE: 
	qualora abbiate installato un sistema completo di un qualche
	desktop environment, la disinstallazione di PulseAudio potrebbe
	comportare la conseguente disinstallazione di vari elementi del
	sistema desktop, anche importanti e non strettamente legati al-
	l'audio.

	EOPPA
  read -s -N1 -p 'Disinstallare il server di "PulseAudio"? (S/n)'
  echo
  [ "$REPLY" != "n" ] || return
  echo -e '\nRimozione di "pulseaudio"...'
  apt-get -y purge pulseaudio 2>&1 | tee -a "purge.log"
  # do not add autoremove here
}

##############################################################################

function restart_squeezelite() {
  echo -e '\nRiavvio di squeezelite...'
  service squeezelite restart
}

##############################################################################

function install_squeezelite() {
  purge_pulseaudio
  {
    echo -e "\nDownload ed installazione di squeezelite-R2"
    if [ "$(arch)" == "x86_64" ]; then
      MySL="squeezelite_1.8.2+R2-1_amd64.deb"
    else
      MySL="squeezelite_1.8.2+R2-1_i386.deb"
    fi
    wget -nH -nd -c http://www.audiofaidate.org/sw/$MySL	|| fail 'Download dei pacchetti di squeezelite-R2 fallito.'
    gdebi --non-interactive $MySL				|| fail 'Installazione dei pacchetti di squeezelite-R2 fallita.'
    service squeezelite stop
  } 2>&1|tee -a install_squeezelite.log
  pausa
  select_outupt_dev
  select_sample_rate_range
  [ -f /etc/default/squeezelite ] && mv -f /etc/default/squeezelite /etc/default/squeezelite.bak
  cat <<-EOSLC > /etc/default/squeezelite
	# Defaults for squeezelite initscript
	# sourced by /etc/init.d/squeezelite
	# installed at /etc/default/squeezelite by the maintainer scripts

	# The name for the squeezelite player:
	SL_NAME="R2@\$(hostname -s)"

	# ALSA output device:
	#SL_SOUNDCARD="hw:0,0"
	#SL_SOUNDCARD="hw:1,0"
	#SL_SOUNDCARD="default:CARD=Amanero"
	#SL_SOUNDCARD="hw:CARD=x20,DEV=0"
	#SL_SOUNDCARD="front:CARD=D20,DEV=0"

	# Squeezebox server (Logitech Media Server):
	# Uncomment the next line if you want to point squeezelite at the IP address
	# of your squeezebox server. This is usually unnecessary as the server is
	# automatically discovered.
	#SB_SERVER_IP="192.168.x.y"

	# Additional options to pass to squeezelite.
	# For details, see: man squeezelite
	# Please do not include -z to make squeezelite daemonise itself.
	#
	#SB_EXTRA_ARGS="-C 1 -a 100:3:16:1 -x -u vME:0::64:90 -r 44100-384000"
	#SB_EXTRA_ARGS="-C 1 -a 200:6:24:1 -x -u vIE:2::64:95 -r 352800,384000"
	#SB_EXTRA_ARGS="-C 1 -a 300:9:32:1 -x -u vLE:8::64:98 -r 192000"
	#SB_EXTRA_ARGS="-C 1 -a 100:3:32:1 -x -b 65536:65536 -x -u vIE:32::64:91 -r 384000"
	#SB_EXTRA_ARGS="-C 1 -a 100:3:$bit_depth:1 -x -b 3072:4096 -u vX:60:3:64:91:95:25 -r $ratesRange -d all=info -f /tmp/squeezelite.log"
	SB_EXTRA_ARGS="-C 1 -a 100:3:$bit_depth:1 -x -b 3072:4096 -u vX:60:3:64:91:95:25 -r $ratesRange"
	
	EOSLC
  if [ "$myOutputDev" != "default" ]; then
    sed -r -i ":a;N;\$!ba;s/(#SL_SOUNDCARD\S+\n\s+)+/\1SL_SOUNDCARD=\"$myOutputDev\"\n\n/g" /etc/default/squeezelite  
  fi
  run_alsamixer
  restart_squeezelite
  cat <<-EOSLM > "squeezelite_notice.txt"
	
	Il sistema è stato preconfigurato e dovrebbe già essere perfettamente
	funzionante, senza bisogno di ulteriori interventi.
	
	Qualora ve ne fosse l'esigenza, se si ha sufficiente dimestichezza con
	il sistema è comunque possibile personalizzare le opzioni di avvio di
	squeezelite modificando il relativo file di configurazione, ad esempio
	utilizzando l'editor "nano":

	  nano /etc/default/squeezelite
	
	In particolare, per facilitare l'identificazione e la risuluzione di
	eventuali problemi che si dovessero riscontrare è possibile abilitare
	le funzioni di logging di squeezelite.
	Per farlo è sufficiente "scommentare" la riga che contiene le opzioni:
	
	  -d all=debug -f /tmp/squeezelite.log
	
	cioè rimuovere il carattere '#' presente all'inizio della riga stessa
	e quindi disabilitare (commentare) la riga adiacente, precedentemente
	attiva, aggiungendo il medesimo carattere '#' all'inizio di tale riga.

	Dopo aver modificato il file di configurazione, per rendere effettive
	le modifiche appena fatte è necessario riavviare il relativo servizio
	utilizzando il comando:

	  service squeezelite restart

	oppure riavviare il sistema.

	Qualora abbiate abilitato il logging come indicato, per visualizzare
	il file di registro potete dare il comando:
	
	  less /tmp/squeezelite

	Potete anche monitorare gli aggiornamenti in tempo reale, utilizzando
	invece il comando:
	
	  tail -f /tmp/squeezelite

	(per uscire da 'less' premete il tasto 'q'; per terminare l'esecuzione
	di 'tail -f' premete invece contemporaneamente i tasti 'Ctrl' e 'c').

	ATTENZIONE:
	
	*) Come suggerito dal suo nome, il file system "/tmp" è destinato
	a contenere files temporanei. In molti sistemi è automaticamente e
	completamente "ripulito" (svuotato) all'avvio del sistema. In altri
	potrebbe addirittura essere ospitato su un "RAM disk".
	Se avete motivo di voler conservare un file di log di squeezelite,
	non dimenticate di copiarlo altrove prima di arrestare o riavviare
	il sistema.

	*) Le funzioni di logging possono interferire con le prestazioni
	del sistema. Inoltre, qualora il file system "/tmp" risieda su di
	una memoria di massa a stato solido quale un SSD, un "pen-drive"
	USB, una scheda "Compact Flash", ecc, le continue scritture del
	file di log possono causarne l'invecchiamento precoce.
	Pertanto, una volta terminato il debugging e verificato che tutto
	funzioni correttamente, si raccomanda caldamente di disabilitarle.
	
	EOSLM
}


##############################################################################

function install_LMS() {
  {
    echo -e "\nDownload ed installazione di LMS v7.9 (latest nightly build)"
    wget -nH -nd -r -np -l1 -c -A '*.deb' http://downloads.slimdevices.com/nightly/?ver=7.9
    gdebi --non-interactive  logitechmediaserver_7.9*_all.deb
  } 2>&1|tee install_LMS.log
  cat <<-EOLMS > "LMS_notice.txt"

	ATTENZIONE: LMS è stato installato e dovrebbe già essere attivo. Prima
	di cominciare ad utilizzarlo dovrete però provvedere a configurarlo per
	mezzo della sua interfaccia Web.
	
	Personalizzazioni più "spinte" potrebbero richiedere la modifica dei 
	files di configurazione di LMS (operazione vivamente sconsigliata, in
	special modo ai meno esperti). I files in questione sono:

	  /etc/default/logitechmediaserver
	  /etc/squeezeboxserver/convert.conf
	  /etc/squeezeboxserver/modules.conf
	  /etc/squeezeboxserver/types.conf

	Dopo aver modificato (attraverso l'interfaccia web) impostazioni che 
	richiedono il riavvio di LMS o modificato i files di configurazione, 
	per rendere effettive le modifiche dovete riavviare il servizo con il 
	comando:

	  service logitechmediaserver restart

	oppure riavviare il sistema.

	EOLMS
}

##############################################################################
# main - execution begins here
##############################################################################
clear
cat <<-EHEAD

	Easy Audio Setup: installazione e configurazione guidata di sistemi
	audio basati su Logitech Media Server + Squeezelite(-R2) in ambienti
	Debian GNU/Linux 8.x "Jessie" (e compatibili).
	
	Copyright Paolo 'UnixMan' Saggese <pms@audiofaidate.org>, 2015
	
	Released under the terms of the GNU General Public License, see:
	http://www.gnu.org/copyleft/gpl.html
	
	Versione: $EAS_VERSION
	Grazie a:
	Filippo 	"antonellocaroli"	@ neXthardware.com forum
	Giovanni	"BigTube"		@ neXthardware.com forum
	Marco  		"marcoc1712" 		@ neXthardware.com forum

EHEAD
run_as_root	# run this first!
pausa		# dopo run_as_root
check_for_updates
check_debian_version
setup_workdir 	# N.B.: da eseguire dopo check_for_updates e run_as_root!
select_install_type
echo -e '\nSetup di base ed ottimizzazioni varie...'
disable_swap
uninstall_syslogger
fstab_setup
grub_setup
limits_setup
udev_setup
sysctl_setup
rclocal_setup
basic_packages_setup
install_liquorix_kernel
echo -e '\nSetup di base completato.'
# Installazione degli elementi del sistema selezionato
echo -e "\nSetup sistema '$TipoSistema':"
case "$TipoSistema" in
  player)
    install_squeezelite
    ;;
  server)
    install_LMS
    ;;
  completo)
    install_squeezelite
    install_LMS
    restart_squeezelite
    ;;
esac
echo -e "\nSetup completato."
pausa
if ls -1 *.txt >/dev/null 2>&1 ; then
  cat <<-EON
	Saranno ora visualizzate le note finali, che si prega di leggere
	con la massima attenzione.
	Potete consultarle nuovamente in qualsiasi momento, insieme ai log 
	dettagliati di quanto appena fatto, dando i comandi:
	
	  cd "$myWorkdir"
	  ls 
	  less *.txt *.log
	
	(all'interno di 'less' potete utilizzare i tasti freccia e quelli 
	PgUp/PgDn per scorrere il testo; premete il tasto "q" per uscire).
	EON
  pausa
  for file in *.txt ; do
    less "$file"
  done
fi
echo -e "\nThat's all, folks!\n\a"
