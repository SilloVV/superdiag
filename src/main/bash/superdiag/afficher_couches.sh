#!/bin/bash

#Dependance
source "/home/pharmagest/superdiag/util_diagnostic.sh"

# Fonction pour obtenir la description d'un service
get_service_description() {
	local service_name=$1
	local init_script="/etc/init.d/$service_name"
	if [[ -f $init_script ]]; then
		# Extraire la premiere ligne de commentaire comme description
		local description=$(grep -m 1 -i 'description' "$init_script" | sed 's/#//g' | sed 's/description://i' | tr -d '\n')
		echo "$description"
	else
		:
	fi
}

#Fonction pour extraire les services et couches de lancement
extract_name_and_layer_of_services() {
	#declarer un dictionnaire
	declare -A services_by_layer

	for symlink in /etc/rc5.d/S*; do
		service=$(basename "$symlink")
		couche=${service:1:2}
		service_name=${service:3}

		# Ajouter le service a la liste des services pour la couche
		services_by_layer["$couche"]+="$service_name "
	done

	for couche in "${!services_by_layer[@]}"; do
		echo "$couche:${services_by_layer[$couche]}"
	done
}

print_table() {
	printf "%-4s | %-30s | %-65s \n" "Layer" "Service" "Description"
	printf "%-4s | %-30s | %-65s \n" "-----" "------------------------------" "-------------------------------------------------------------"

	services_data=$(extract_name_and_layer_of_services)

	declare -A services_by_layer

	# Lire les donnees retournees et les stocker dans un tableau
	while IFS=: read -r layer services; do
		services_by_layer["$layer"]="$services"
	done <<<"$services_data"

	previous_layer=""

	# Afficher les services par couche de maniere decroissante
	for couche in $(echo "${!services_by_layer[@]}" | tr ' ' '\n' | sort -nr); do
		if [[ "$couche" != "$previous_layer" && "$previous_layer" != "" ]]; then
			echo "===================================================================================================================="
		fi

		for service in ${services_by_layer[$couche]}; do
			description=$(get_service_description "$service")
			printf "%-4s | %-30s --> %-65s \n" "$couche" "$service" "$description"
		done

		previous_layer="$couche"
	done
}
