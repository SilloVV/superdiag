#!/bin/bash

# Chemin du fichier de log
LOG_FILE="./salt_minion_connectivity.log"

# Verifier et creer le fichier s'il n'existe pas
[ ! -f $LOG_FILE ] && touch $LOG_FILE

echo " " >>"$LOG_FILE"

# Fonction pour enregistrer dans le fichier journal
log_minion_status() {
	local minion_id=$1
	local status=$2
	local timestamp=$3
	log_entry="$minion_id - $status - Depuis $timestamp"
	echo "$log_entry" >>"$LOG_FILE"
	echo "$log_entry"
}

# Verifier la connectivite des minions
ping_minions() {
	minions=$(salt-key -L | awk '/Accepted Keys:/,/^[[:space:]]*$/' | grep -E '^[a-zA-Z0-9._-]+$')
	for minion in $minions; do
		response=$(salt "$minion" test.ping 2>/dev/null)
		if [[ "$response" == *"True"* ]]; then
			status="Online"
			timestamp=$(date +"%d-%m-%Y %H:%M:%S")
		else
			status="Offline"
			# Recuperer la derniere date du fichier de log si disponible
			timestamp=$(grep "^$minion " $LOG_FILE | tail -n 1 | awk -F ' - ' '{print $4}')
			if [ -z "$timestamp" ]; then
				timestamp="Aucune connexion"
			fi
		fi
		log_minion_status "$minion" "$status" "$timestamp"
	done
}

# DEBUT
ping_minions
