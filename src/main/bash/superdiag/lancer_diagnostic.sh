#!/bin/bash

#Dependance
source "./back_diagnostic.sh"
source "./util_diagnostic.sh"
source "./menu_diagnostic.sh"

display_services_info() {
	gather_services_info
	echo -e "\n${RESETCOLOR}> Services actifs :"
	for service in "${green_services[@]}"; do
		IFS=' ' read -r service_name status substatus <<<"$service"
		echo -e ".Service: ${service_name} --> actif-${VERT}[OK]${RESETCOLOR}"
	done

	for service in "${yellow_services[@]}"; do
		IFS=' ' read -r service_name status substatus <<<"$service"
		echo -e ".Service: ${service_name} --> termine${VERT}[OK]${RESETCOLOR}"
	done

	echo -e "\n${RESETCOLOR}> Services inactifs (a possiblement redemarrer):"
	for service in "${orange_services[@]}"; do
		IFS=' ' read -r service_name status substatus <<<"$service"
		echo -e ".Service: ${service_name} --> ${ORANGE}inactif${RESETCOLOR}-${ORANGE}[KO]${RESETCOLOR}"
	done

	echo -e "\n${RESETCOLOR}> Services dont le statut est inconnu de systemctl:"
	for service in "${blue_services[@]}"; do
		IFS=' ' read -r service_name status substatus <<<"$service"
		echo -e ".Service: ${service_name} --> inconnu-${BLEU}[?]${RESETCOLOR}"
	done

	echo -e "\n${RESETCOLOR}> Services echoues ou inactifs (en rouge):"
	for service in "${red_services[@]}"; do
		IFS=' ' read -r service_name status substatus <<<"$service"
		echo -e ".Service: ${service_name} --> ${ROUGE}$substatus${RESETCOLOR}-${ROUGE}[KO]${RESETCOLOR}"
	done

	# Afficher le tableau de statistiques
	echo -e "\n${RESETCOLOR}> Statistiques des services:\n"
	echo -e "${BLEU}=================================================${RESETCOLOR}"
	printf "|| %-20s %10s / %-10s\n" "  Couleur" "Nombre" "Total      ||"
	printf "|| %-20s %10s   %-10s\n" "  -------" "------" "-----      ||"
	printf "||${VERT} %-20s %10d${RESETCOLOR} / %-10d ||\n" "Services actifs:" "$nb_green" "$nb_total"
	printf "||${JAUNE} %-20s %10d${RESETCOLOR} / %-10d ||\n" "Services termines:" "$nb_yellow" "$nb_total"
	printf "||${ORANGE} %-20s %10d${RESETCOLOR} / %-10d ||\n" "Services inactifs:" "$nb_orange" "$nb_total"
	printf "||${ROUGE} %-20s %10d${RESETCOLOR} / %-10d ||\n" "Services echoues:" "$nb_red" "$nb_total"
	printf "||${BLEU} %-20s %10d${RESETCOLOR} / %-10d ||\n" "Services inconnus:" "$nb_blue" "$nb_total"
	echo -e "${BLEU}=================================================${RESETCOLOR}"
	echo -e "\n"
}

# Fonction pour redemarrer les services
reboot_services() {
	if [ ${#rebootable_services[@]} -eq 0 ]; then
		echo "Aucun service a  redemarrer."
		return
	fi

	echo -e "Quel service voulez-vous redemarrer ?"
	PS3="Choisissez un service : "
	options=("${rebootable_services[@]}" "retour")
	select service in "${options[@]}"; do
		if [[ $REPLY -ge 1 && $REPLY -le ${#rebootable_services[@]} ]]; then
			echo "Redemarrage de $service..."
			systemctl restart "$service"
			./afficher_espace_logs.sh
			./verifications_http/all_verifications.sh

			break
		elif [[ $REPLY -eq ${#options[@]} ]]; then
			launch_menu
			break
		else
			echo "Selection invalide. Veuillez choisir un numero valide."
		fi
	done
}

display_services_info
./afficher_espace_logs.sh
./verifications_http/all_verifications.sh
launch_menu
