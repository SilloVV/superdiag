#!/bin/bash

#Couleurs
VERT="\e[1;32m"         #services en activite
ORANGE="\033[38;5;214m" #services inactifs
BLEU="\e[1;36m"         #services inconnus par systemctl
RESETCOLOR="\e[0m"      #couleur par defaut

afficher_info_systeme() {
	# Afficher l'espace RAM
	echo -e "\n${VERT}=== Espace RAM/SWAP ===${RESETCOLOR}"
	free -h

	# Afficher l'espace disque
	echo -e "\n${VERT}=== Espace disque ===${RESETCOLOR}"
	df -h -t ext4

	# Afficher l'utilisation du CPU
	echo -e "\n${BLEU}=== Utilisation du CPU ===${RESETCOLOR}"
	top -bn1 | grep "Cpu(s)" | awk '{print "Utilisation utilisateur: " $2 "%\nUtilisation système: " $4 "%\nUtilisation nice: " $6 "%\nTemps  inactivte: " $8 "%\nTemps d attente IO: " $10 "%\nInterruptions materielles: " $12 "%\nInterruptions logicielles: " $14 "%\nTemps vole: " $16 "%"}'
	# Afficher les 10 processus java qui utilisent le plus de RAM
	echo -e "\n${ORANGE}=== Processus Java utilisant le plus de RAM ===${RESETCOLOR}"
	echo -e "PID      User       Mem   CPU   Command             Classe Java"
	ps -eo pid,user,%mem,%cpu,comm,args --sort=-%mem | grep java | head -n 10 | while read -r line; do
		pid=$(echo "$line" | awk '{print $1}')
		user=$(echo "$line" | awk '{print $2}')
		mem=$(echo "$line" | awk '{print $3}')
		cpu=$(echo "$line" | awk '{print $4}')
		comm=$(echo "$line" | awk '{print $5}')
		classe_java=$(echo "$line" | awk '{for(i=6;i<=NF;i++) print $i}' | tail -n 2 | tr '\n' ' ')
		printf "%-8s %-10s %-5s %-5s %-20s %s\n" "$pid" "$user" "$mem" "$cpu" "$comm" "$classe_java"
	done

	# Afficher les 10 processus java qui utilisent le plus de CPU
	echo -e "\n${ORANGE}=== Processus Java utilisant le plus de CPU ===${RESETCOLOR}"
	echo -e "PID      User       Mem   CPU   Command             Classe Java"
	ps -eo pid,user,%mem,%cpu,comm,args --sort=-%cpu | grep java | head -n 10 | while read -r line; do
		pid=$(echo "$line" | awk '{print $1}')
		user=$(echo "$line" | awk '{print $2}')
		mem=$(echo "$line" | awk '{print $3}')
		cpu=$(echo "$line" | awk '{print $4}')
		comm=$(echo "$line" | awk '{print $5}')
		classe_java=$(echo "$line" | awk '{for(i=6;i<=NF;i++) print $i}' | tail -n 2 | tr '\n' ' ')
		printf "%-8s %-10s %-5s %-5s %-20s %s\n" "$pid" "$user" "$mem" "$cpu" "$comm" "$classe_java"
	done

	rafraichir_info_systeme
}

# Fonction pour rafraîchir les informations des processus Java sur demande
rafraichir_info_systeme() {
	read -p "Appuyez sur Entrée pour rafraîchir les informations sur les processus Java (q pour quitter)..." choix
	if [ "$choix" = "q" ]; then
		exit 0
	fi
	afficher_info_systeme
}

# Appeler la fonction
afficher_info_systeme
