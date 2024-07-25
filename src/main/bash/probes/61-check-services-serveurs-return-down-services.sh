#!/usr/bin/env bash

# =>maxwait: 30
# =>cron: * * * * *
# =>lgo: LGPIFR

# DESC: Sonde qui permet de remonter les service dans les etats failed et inactive.

set -o pipefail

WORKDIR=$(dirname "$(readlink -f "$0")")
UTILDIR="$WORKDIR/../util"
# shellcheck source=../util/functions.sh
source "$UTILDIR/functions.sh"

#Fonctions utilisees
source "/home/pharmagest/superdiag/util_statut.sh"

# Listes des statuts et etats que l'on veut remonter
USEFUL_STATUSES=("inactive" "failed")

# Initialisation de la liste des services down
down_services=""

# Fonction pour vérifier l'etat des services et ajouter le service a la liste si le service est failed ou inactive
return_to_splunk_failed_inactive_services() {
	local service_name=$1
	local status=$(check_status $service_name)

	if [[ " ${USEFUL_STATUSES[@]} " =~ " ${status} " ]]; then
		if [ -z "$down_services" ]; then
			down_services="$service_name"
		else
			down_services="$down_services,$service_name"
		fi
	fi
}

# Fonction pour extraire et verifier l'uptime
check_uptime() {
    # Extraire le temps d'uptime
    uptime_output="$1"

    # Initialiser les variables
    weeks=0
    days=0
    hours=0
    minutes=0

    # Extraire les semaines
    if [[ "$uptime_output" =~ ([0-9]+)\ week ]]; then
        weeks=${BASH_REMATCH[1]}
    fi

    # Extraire les jours
    if [[ "$uptime_output" =~ ([0-9]+)\ day ]]; then
        days=${BASH_REMATCH[1]}
    fi

    # Extraire les heures et les minutes pour le format "hours, minutes"
    if [[ "$uptime_output" =~ ([0-9]+)\ hours?,\ ([0-9]+)\ minutes? ]]; then
        hours=${BASH_REMATCH[1]}
        minutes=${BASH_REMATCH[2]}
    fi

    # Extraire les heures uniquement
    if [[ "$uptime_output" =~ ([0-9]+)\ hours? ]]; then
        hours=${BASH_REMATCH[1]}
    fi

    # Extraire les minutes uniquement
    if [[ "$uptime_output" =~ ([0-9]+)\ minutes? ]]; then
        minutes=${BASH_REMATCH[1]}
    fi

    # Calculer le total des minutes
    total_minutes=$((weeks * 7 * 24 * 60 + days * 24 * 60 + hours * 60 + minutes))

    echo "$total_minutes"
}
# Fonction pour executer la sonde si l'uptime est superieur a 15 minutes
execute_probe() {
	# Verification des services
	for service in "${services_to_supervise[@]}"; do
		return_to_splunk_failed_inactive_services "$service"
	done

	# Log la cle concaténée seulement s'il y a des services down
	if [ ! -z "$down_services" ]; then
		toLog "failed_services=\"$down_services\" "
	fi

}

# Definir la valeur seuil pour l'uptime
UPTIME_A_DEPASSER=15

# LANCEMENT DE LA SONDE SI L'UPTIME EST SUPERIEUR A UPTIME_A_DEPASSER MINUTES
total_minutes=$(check_uptime "$(uptime -p)")
echo "Temps depuis le dernier (re)boot : $total_minutes minutes"

if [ "$total_minutes" -gt "$UPTIME_A_DEPASSER" ]; then
	execute_probe
else
	echo "uptime inferieur a $UPTIME_A_DEPASSER minutes."
fi
