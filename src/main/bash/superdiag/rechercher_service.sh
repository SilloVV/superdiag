#!/bin/bash

# Dependances
source "/home/pharmagest/superdiag/util_diagnostic.sh"

#Fonction search_services_on_systemctl: entrer un mot cle et afficher une liste de services du systemctl
search_services_on_systemctl() {
	echo -n "Entrez le nom du service a rechercher: "
	read service_name

	# Rechercher les services disponibles avec grep, les services inactifs affichent d'abord un "*" en $1 d'ou la condition if.
	found_services=$(systemctl list-units --all | awk '{if ($1 == "*") print $2; else print $1}' | grep -i "$service_name" | grep -v '\.device$' | grep -v '\.slice$')

	if [[ -z "$found_services" ]]; then
		echo "Aucun service trouve pour '$service_name'."
		return 1
	fi

	echo "Services trouves :"
	services=($found_services)
	count=1
	for service in "${services[@]}"; do
		echo "$count) $service"
		((count++))
	done
}

# Fonction pour chercher, selectionner un service et  afficher le statut d'un service sur le serveur
search_service_status() {
	# Appeler la fonction pour rechercher les services disponibles
	search_services_on_systemctl || return 1 # Sortir si aucun service trouve

	# Verifier le nombre de services retournes
	num_services=${#services[@]}
	if [[ $num_services -eq 0 ]]; then
		echo "Aucun service trouve."
		return 1
	elif [[ $num_services -eq 1 ]]; then
		service_name=${services[0]} # Selection automatique du seul service trouve
	else
		echo -n "Choisissez un service en entrant le numero correspondant : "
		read choice

		if [[ $choice -gt 0 && $choice -le $num_services ]]; then
			service_name=${services[$((choice - 1))]}
		else
			echo "Selection invalide. Veuillez reessayer."
			return 1
		fi
	fi

	local status=$(check_status "$service_name")
	local substatus=$(check_substatus "$service_name")

	# Associer une couleur
	if [[ $status == "active" ]]; then
		status_color=$VERT
	elif [[ $status == "unknown" ]]; then
		status_color=$BLEU
	else
		status_color=$ROUGE
	fi

	if [[ $substatus == "running" ]]; then
		substatus_color=$VERT
	elif [[ $substatus == "exited" ]]; then
		substatus_color=$JAUNE
	elif [[ $substatus == "unknown" ]]; then
		substatus_color=$BLEU
	else
		substatus_color=$ROUGE
	fi

	echo -e "\n${status_color}Service: ${service_name}${NOCOLOR} \t| Etat: ${status_color}${status}${NOCOLOR} \t| Sous-etat: ${substatus_color}${substatus}${NOCOLOR}"

	# Afficher les informations et les avertissements du journalctl associes au service
	echo -e "\n>Journalctl: ${BLEU}info pour $service_name :${NOCOLOR}"
	journalctl_infos_output=$(journalctl -u "$service_name" -n 20 --no-pager -p info)

	if [[ -z "$journalctl_infos_output" ]]; then
		echo "--> pas d'infos dans le journalctl"
	else
		echo "$journalctl_infos_output"
	fi

	echo "---------FIN-----------"

}
