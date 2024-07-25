#!/bin/bash

#Return codes
OK=0
SERVICE_HORS_LISTE=1

#Dependance

if [[ -f "./util_statut.sh" ]]; then
	source "./util_statut.sh"
elif [[ -f "$(dirname "$0")/../../main/bash/superdiag/util_statut.sh" ]]; then
	source "$(dirname "$0")/../../main/bash/superdiag/util_statut.sh"
elif [[ -f "../../main/bash/superdiag/util_statut.sh" ]]; then
	source "../../main/bash/superdiag/util_statut.sh"
elif [[ -f "../../../main/bash/superdiag/util_statut.sh" ]]; then
	source "../../../main/bash/superdiag/util_statut.sh"
elif [[ -f "/home/pharmagest/superdiag/util_statut.sh" ]]; then
	source "/home/pharmagest/superdiag/util_statut.sh"
else
	echo "le fichier util_statut.sh est introuvable"
fi

#fonctions pour l'affichage des etats

# Fonction check_substatus : trouver le sous-etat d'un service
check_substatus() {
	local service_name="$1"
	local substatus=$(systemctl show "$service_name" | grep ^SubState= | awk -F= '{print $2}')

	if [[ $substatus == "exited" || $substatus == "failed" || $substatus == "dead" ]]; then
		local is_active=$(systemctl is-active "$service_name")
		if [[ $is_active == "unknown" ]]; then
			substatus="unknown"
		fi
	fi

	echo "$substatus"
}

# Fonction pour verifier si un service est bien dans les services verifies: liste services_to_check
service_in_checked_list() {
	local service_name="$1"

	[[ " ${services_to_check[@]} " =~ " ${service_name} " ]]
}

# Fonction check_status_in_list: chercher le status dans la liste des services_to_check
check_status_in_list() {
	local service_name="$1"

	if ! service_in_checked_list "$service_name"; then
		echo "Service non trouve: $service_name"
		return $SERVICE_HORS_LISTE
	fi
	check_status "$service_name"
}

# Fonction check_substatus_in_list: chercher les sous-status dans la liste des services to check
check_substatus_in_list() {
	local service_name="$1"

	if ! service_in_checked_list "$service_name"; then
		echo "Service non trouve : $service_name"
		return $SERVICE_HORS_LISTE
	fi
	check_substatus "$service_name"
}
