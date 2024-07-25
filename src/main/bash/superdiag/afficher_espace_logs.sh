#!/bin/bash

# Definition des couleurs
BLEU="\e[1;36m"    #services inconnus par systemctl
RESETCOLOR="\e[0m" #couleur par defaut

#Script qui verifie la taille des repertoires donnees dans la liste

directories_of_logs=(
	"/var/log"
)

check_directory_sizes() {

	# List of directories or files to check
	local items=("$@")

	for item in "${items[@]}"; do
		if [[ -e $item ]]; then
			# Get the size of the directory or file in bytes
			item_size=$(du -sb "$item" | awk '{print $1}')

			# Convert the size to MB
			item_size_mb=$((item_size / 1024 / 1024))

			# Get the human-readable size
			human_readable_size=$(du -sh "$item" | awk '{print $1}')

			# Set color based on the size
			if ((item_size_mb > 1500)); then
				color=$ROUGE
			elif ((item_size_mb > 750)); then
				color=$ORANGE
			else
				color=$VERT
			fi

			# Print the result with the appropriate color
			echo -e "${color}                          Taille de '$item' : $human_readable_size${RESETCOLOR}\n"
		else
			echo -e "${ROUGE}$item does not exist.${NC}"
		fi
	done
}
#Fonction qui affiche les 30 fichier de log les plus lourd du /var/log
display_top_log_files() {
	local log_directory="/var/log"
	local num_files=20

	echo -e "> Top $num_files des fichiers .log les plus lourds de '$log_directory':\n"

	files=$(find "$log_directory" -type f -name "*.log" -exec du -h {} + | sort -rh | head -n "$num_files")

	total_size=0
	while IFS= read -r line; do
		size=$(echo "$line" | awk '{print $1}')
		filepath=$(echo "$line" | awk '{print $2}')
		printf " %-10s %s\n" "$size" "$filepath"

	done <<<"$files"

}

#Fonction pour afficher les 30 repertoires de logs les plus lourds
display_top_log_directories() {
	local log_directory="/var/log"
	local num_dirs=20

	echo -e "\n> Top $num_dirs des repertoires les plus lourds de '$log_directory':\n"

	dirs=$(du -h --max-depth=1 "$log_directory" | grep -v "^$(du -sh "$log_directory" | cut -f1)" | sort -rh | head -n "$num_dirs")

	while IFS= read -r line; do
		size=$(echo "$line" | awk '{print $1}')
		dirpath=$(echo "$line" | awk '{print $2}')
		printf " %-10s %s\n" "$size" "$dirpath"
	done <<<"$dirs"
}

echo -e "${BLEU}========================================================================================${RESETCOLOR}"
echo -e "${BLEU}                                    VOLUMETRIE ${RESETCOLOR}\n"
check_directory_sizes "${directories_of_logs[@]}"
display_top_log_files
display_top_log_directories
echo -e "\n${BLEU}========================================================================================${RESETCOLOR}"
