#!/bin/bash

# Sourcing des fonctions a  partir de Service_status_fonctions.sh
if [[ -f "./util_diagnostic.sh" ]]; then
	source "./util_diagnostic.sh"
elif [[ -f "$(dirname "$0")/../../main/bash/superdiag/util_diagnostic.sh" ]]; then
	source "$(dirname "$0")/../../main/bash/superdiag/util_diagnostic.sh"
elif [[ -f "../../main/bash/superdiag/util_diagnostic.sh" ]]; then
	source "../../main/bash/superdiag/util_diagnostic.sh"
elif [[ -f "../../../main/bash/superdiag/util_diagnostic.sh" ]]; then
	source "../../../main/bash/superdiag/util_diagnostic.sh"
else
	echo "le fichier util_diagnostic.sh est introuvable"
fi

# Definition des couleurs
VERT="\e[1;32m"         #services en activite
ROUGE="\e[1;31m"        #services inactifs/echouees
JAUNE="\e[1;33m"        #services termines
ORANGE="\033[38;5;214m" #services inactifs
BLEU="\e[1;36m"         #services inconnus par systemctl
RESETCOLOR="\e[0m"      #couleur par defaut

#Definition des listes
green_services=()
yellow_services=()
red_services=()
blue_services=()
orange_services=()
down_services=()
rebootable_services=()
nb_green=0
nb_yellow=0
nb_red=0
nb_blue=0
nb_orange=0

fill_services_lists() {
	local status=$1
	local substatus=$2
	local service=$3

	if [[ $substatus == "exited" ]]; then
		yellow_services+=("$service $status $substatus")
		rebootable_services+=($service)
		((nb_yellow++))
	elif [[ $status == "active" ]]; then
		green_services+=("$service $status $substatus")
		rebootable_services+=($service)
		((nb_green++))
	elif [[ $status == "unknown" ]]; then
		blue_services+=("$service $status $substatus")
		rebootable_services+=($service)
		((nb_blue++))
	elif [[ $status == "inactive" ]]; then
		orange_services+=("$service $status $substatus")
		rebootable_services+=($service)
		down_services+=($service)
		((nb_orange++))
	else
		red_services+=("$service $status $substatus")
		rebootable_services+=($service)
		down_services+=($service)
		((nb_red++))
	fi

	local nb_total=$((nb_green + nb_yellow + nb_red + nb_blue + nb_orange))
}

update_global_status() {
	local down_services=("$@")

	if [ ${#down_services[@]} -eq 0 ]; then
		echo "0" >statut_global.txt
	else
		echo "1" >statut_global.txt
	fi
}

gather_services_info() {
	for service in "${services_to_check[@]}"; do
		local status=$(check_status_in_list "$service")
		local substatus=$(check_substatus_in_list "$service")
		fill_services_lists "$status" "$substatus" "$service"
	done

	update_global_status "${down_services[@]}"
}
