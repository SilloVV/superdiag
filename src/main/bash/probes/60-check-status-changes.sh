#!/bin/bash

# =>maxwait: 30
# =>cron: */15 * * * *
# =>lgo: LGPIFR

# DESC: Sonde qui permet de remonter les service dans les etats failed et inactive.

set -o pipefail

WORKDIR=$(dirname "$(readlink -f "$0")")
UTILDIR="$WORKDIR/../util"

#dependances
source "$UTILDIR/functions.sh"
statuts_prec="/home/pharmagest/superdiag/services_status_prec.txt"

if [[ -f "$(dirname "$0")/../superdiag/util_diagnostic.sh" ]]; then
        source "$(dirname "$0")/../superdiag/util_diagnostic.sh"
elif [[ -f "/home/pharmagest/superdiag/util_diagnostic.sh" ]]; then
        source "/home/pharmagest/superdiag/util_diagnostic.sh"
else
        echo "util_diagnostic.sh introuvable"
fi

NB_ITERATIONS_AVANT_REMONTEE_SPLUNK=3
UPTIME_A_DEPASSER=15

# Initialisation de la liste des services qui passent a inactive et ceux qui repassent a active
down_services=""

re_up_services=""

#Fonction qui cree le fichier statuts_prec s'il n'existe pas
create_file_if_not_existing() {
	local file_path="$1"

	if [ ! -f "$file_path" ]; then
		touch "$file_path"
		echo "fichier $file_path cree"
	fi
}

#Fonction qui appelle write_statuses_in_file si le fichier est vide
call_write_statuses_in_file_if_void_file() {
	local file_path="$1"

	if [ ! -s "$file_path" ]; then
		write_statuses_in_file $file_path
		return 0
	else
		return 2
	fi
}

write_statuses_in_file() {
	local file_path="$1"
	declare -gA compteurs
	>"$file_path" # Vider le fichier avant d'ecrire

	for service in "${services_to_supervise[@]}"; do
		if [ -n "$service" ]; then
			service_name="$service"
			status=$(check_status "$service_name")
			compteur=${compteurs["$service_name"]:="0"}
			echo "$service_name : $status : $compteur" >>"$file_path"
			chmod +x "$file_path"
		fi
	done

	#DEBUG: echo -e "Statuts courants des services ecrits dans $file_path [OK]"
}

# Fonction qui lit le nom, l'etat et le compteur des services du fichier statuts_prec et remplit un tableau avec ces valeurs
initialize_prev_status_in_array() {
	local file_path="$1"
	declare -gA saved_statuses
	declare -gA compteurs

	if [ -f "$file_path" ]; then
		while IFS= read -r line; do
			service_name=$(echo "$line" | cut -d' ' -f1)
			prev_status=$(echo "$line" | cut -d' ' -f3)
			compteur=$(echo "$line" | cut -d' ' -f5)
			saved_statuses["$service_name"]="$prev_status"
			if [ -z "${compteurs["$service_name"]}" ]; then
				compteurs["$service_name"]="${compteur:-0}"
			fi
		done <"$file_path"
	fi

	create_file_if_not_existing "$file_path"
	call_write_statuses_in_file_if_void_file "$file_path"

}

# Fonction qui lit le nom et l'etat courant des services et remplit un tableau avec ces valeurs
initialize_current_status_in_array() {
	declare -gA current_statuses

	for service in "${services_to_supervise[@]}"; do
		if [ -n "$service" ]; then
			service_name="$service"
			current_status=$(check_status "$service_name")
			current_statuses["$service_name"]="$current_status"
		fi
	done

}

# Fonction pour comparer les statuts du fichier precedent (statuts_prec) avec les statuts actuels des services
compare_statuses() {
	declare -gA saved_statuses
	declare -gA compteurs
	declare -A current_statuses

	file_path=$1
	eval "$(echo "$2")"
	eval "$(echo "$3")"

	for service_name in "${!current_statuses[@]}"; do
		current_status="${current_statuses["$service_name"]}"
		previous_status="${saved_statuses["$service_name"]}"
		if [ "${compteurs["$service_name"]}" -ge 3 ] && [ "$current_status" = "active" ]; then
			if [ -z "$re_up_services" ]; then
				re_up_services="$service_name"
			else
				re_up_services="$re_up_services,$service_name"
			fi
			compteurs["$service_name"]=0
		elif [ "$current_status" = "active" ]; then
			compteurs["$service_name"]=0
		elif [ "$previous_status" = "active" ] && ([ "$current_status" = "inactive" ] || [ "$current_status" = "failed" ]); then
			compteurs["$service_name"]=1
		elif [ "${compteurs["$service_name"]}" -ge 1 ] && [ "$previous_status" = "inactive" ] && [ "$current_status" = "inactive" ]; then
			compteurs["$service_name"]=$((compteurs["$service_name"] + 1))
		elif [ "${compteurs["$service_name"]}" -ge 1 ] && [ "$previous_status" = "inactive" ] && [ "$current_status" = "failed" ]; then
			compteurs["$service_name"]=$((compteurs["$service_name"] + 1))
		elif [ "${compteurs["$service_name"]}" -ge 1 ] && [ "$previous_status" = "failed" ] && [ "$current_status" = "inactive" ]; then
			compteurs["$service_name"]=$((compteurs["$service_name"] + 1))
		elif [ "${compteurs["$service_name"]}" -ge 1 ] && [ "$previous_status" = "failed" ] && [ "$current_status" = "failed" ]; then
			compteurs["$service_name"]=$((compteurs["$service_name"] + 1))
		fi

		if [ "${compteurs["$service_name"]}" -eq $NB_ITERATIONS_AVANT_REMONTEE_SPLUNK ]; then
			#DEBUG:	echo "$service_name : active -> $current_status"

			if [ -z "$down_services" ]; then
				down_services="$service_name"
			else
				down_services="$down_services,$service_name"
			fi

		fi
	done
	#DEBUG: echo "$re_up_services"
	write_statuses_in_file "$file_path"
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
	initialize_prev_status_in_array "$statuts_prec"
	initialize_current_status_in_array

	compare_statuses "$statuts_prec" "$(declare -p saved_statuses)" "$(declare -p current_statuses)"

	# Log la cle concatenee seulement s'il y a des services down
	if [ ! -z "$down_services" ]; then
		# Decomposer down_services en une liste
		IFS=',' read -ra down_services_list <<<"$down_services"

		# Parcourir chaque service et remonter le nom du service correspondant
		for service_name in "${down_services_list[@]}"; do
			toLog "statut_$service_name="KO""
		done
	fi
	if [ ! -z "$re_up_services" ]; then
		# Decomposer down_services en une liste
		IFS=',' read -ra re_up_services_list <<<"$re_up_services"

		# Parcourir chaque service et remonter le nom du service correspondant
		for service_name in "${re_up_services_list[@]}"; do
			toLog "statut_$service_name="OK""
		done
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
