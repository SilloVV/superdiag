#!/bin/bash

# Sourcing des fonctions a  partir de Service_status_fonctions.sh
source "./rechercher_service.sh"
source "./afficher_couches.sh"
source "./rechercher_logs.sh"

# Definition des couleurs
BLEU="\e[1;36m" #services inconnus par systemctl
NOCOLOR="\e[0m" #couleur par defaut

# Fonction pour dessiner une ligne horizontale
draw_line() {
	local width=$1
	for ((i = 0; i < width; i++)); do
		echo -n "--"
	done
}

# Fonction pour afficher le menu avec un style graphique
show_menu() {
	local width=20
	echo " "
	echo -e "                        ${BLEU}+$(draw_line $width)+${NOCOLOR}"
	echo -e "                        ${BLEU}|${NOCOLOR}           Menu de diagnostic           ${BLEU}|${NOCOLOR}"
	echo -e "                        ${BLEU}+$(draw_line $width)+${NOCOLOR}"
	echo -e "                        ${BLEU}|${NOCOLOR} 1. Redemarrer un service               ${BLEU}|${NOCOLOR}"
	echo -e "                        ${BLEU}|${NOCOLOR} 2. Rechercher un service via systemctl ${BLEU}|${NOCOLOR}"
	echo -e "                        ${BLEU}|${NOCOLOR} 3. Afficher les services en couche     ${BLEU}|${NOCOLOR}"
	echo -e "                        ${BLEU}|${NOCOLOR} 4. Trouver un repertoire de logs       ${BLEU}|${NOCOLOR}"
	echo -e "                        ${BLEU}|${NOCOLOR} 5. Utilisation memoire/CPU             ${BLEU}|${NOCOLOR}"
	echo -e "                        ${BLEU}|${NOCOLOR} 6. Analyse memoire avec ncdu           ${BLEU}|${NOCOLOR}"
	echo -e "                        ${BLEU}|${NOCOLOR} 7. Quitter                             ${BLEU}|${NOCOLOR}"
	echo -e "                        ${BLEU}+$(draw_line $width)+${NOCOLOR}"
	echo -n "Choisissez une option (1, 2, 3, 4, 5, 6 ou 7): "
}

# Comportements du menu
launch_menu() {
	while true; do
		show_menu
		read choice
		case $choice in
		1) reboot_services ;;
		2) search_service_status ;;
		3) print_table ;;
		4) launch_logs_finder ;;
		5) ./afficher_statistiques_systeme.sh ;;
		6) ./analyser_memoire_avec_ncdu.sh ;;
		7) exit 0 ;;
		*) echo "Option invalide, veuillez reessayer." ;;
		esac
	done
}
