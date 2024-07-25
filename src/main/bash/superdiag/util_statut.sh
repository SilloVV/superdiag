#!/bin/bash

# Liste de services pour l'outil de diagnostic (je n'ai pas tout mis pour des soucis de confidentialité)
SERVICES_DIAG=( "agenda"  "epson_pcsvcd" "fmd-engine" "fmd_jms"  ) 


#Liste des services pour l'outil de supervision (je n'ai pas tout mis pour des soucis de confidentialité)
SERVICES_SUPER=("birt" "lgpi_verrou_cmde" )

# Fonction check_status : trouver l'etat d'un service
check_status() {
	local service_name="$1"
	local status=$(systemctl show "$service_name" | grep ActiveState | awk -F= '{print $2}')

	# Verifier si le service est vraiment inactif ou bien inconnu
	if [[ $status == "inactive" || $status == "failed" ]]; then
		local service_status_output=$(service "$service_name" status)
		if [[ $service_status_output == *"is running"* || $service_status_output == *"semble d"* || $service_status_output == *"est actif"* ]]; then
			status="active"
		else
			local is_active=$(systemctl is-active "$service_name")
			if [[ $is_active == "unknown" ]]; then
				status="unknown"
			fi
		fi
	fi

	echo "$status"
}

# Liste des services a verifier
services_to_check=("${SERVICES_DIAG[@]}")
services_to_supervise=("${SERVICES_SUPER[@]}")
