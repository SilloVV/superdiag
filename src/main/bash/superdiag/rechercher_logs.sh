#!/bin/bash

# Fonction pour remplacer $SERVICE par le nom du service dans le chemin du fichier
replace_service_name() {
	local path=$1
	local service_name=$2
	path="${path//\$SERVICE/$service_name}"
	path="${path//\$NAME_PROCESS/$service_name}"
	path="${path//\$LOG_NAME/$service_name.log}"
	echo "$path"
}

# Fonction pour extraire les chemins de fichiers de logs a partir d'un fichier donne
extract_log_directory_from_file() {
	local file_path=$1
	grep -i 'log' "$file_path" | grep -Eo '/[^ ]+\.log[^ ]*' | head -n 1
}

# Fonction pour remplacer les variables LOG_DIR et LOG d'un script d'init
replace_LOG_DIR_variable() {
	local service_name=$1
	local init_script=$2
	local log_dir
	local logs_files

	while IFS= read -r line; do
		case "$line" in
		LOG_DIR=*)
			log_dir="${line#LOG_DIR=}"
			log_dir=$(replace_service_name "$log_dir" "$service_name")
			;;
		LOG=*)
			logs_files="${line#LOG=}"
			if [[ $logs_files == *"\$LOG_DIR"* ]]; then
				logs_files="${logs_files/\$LOG_DIR/$log_dir}"
			fi
			logs_files=$(replace_service_name "$logs_files" "$service_name")
			;;
		esac
	done <"$init_script"

	echo "$logs_files"
}

# Fonction pour extraire le repertoire de logs a partir du script d'init du service
get_service_logs_directory() {
	local service_name=$1
	local init_script="/etc/init.d/$service_name"

	if [[ -f $init_script ]]; then
		logs_files=$(replace_LOG_DIR_variable "$service_name" "$init_script")

		if [[ -n $logs_files ]]; then
			echo "$logs_files"
		elif [[ -z $logs_files ]]; then
			logs_files=$(locate $service_name | grep .log)
			echo "$logs_files"
		else
			echo "Aucun fichier de log trouve dans le script d'init."

		fi
	else
		return 1
	fi

}
#Fonction pour extraire la ligne de configuration log4j xml du init script
extract_log4jconfiguration_line() {
	local service_name=$1
	local init_script="/etc/init.d/$service_name"
	grep -E '^\s*-Dlog4j.configuration' "$init_script" | sed -n 's/.*-Dlog4j.configuration=file:\([^ ]*\.xml\).*/\1/p'
}

# Fonction pour rechercher les lignes specifiques associees au repertoire de log dans un fichier XML
rechercher_logs_xml() {
	local fichier=$1

	if [[ ! -f $fichier ]]; then
		echo "Le fichier specifie n'existe pas : $fichier"
		return 1
	fi

	grep -En '<param\s+name="file"\s+value=".*\.log"\s*/>' "$fichier"
}

# Fonction pour extraire le chemin du fichier log du resultat de rechercher_logs_xml
extraire_chemin_log_xml() {
	local ligne=$1
	echo "$ligne" | grep -Eo 'value="/[^"]+\.log"' | sed 's/value="//' | sed 's/"//'
}

#Fonction qui va trouver le chemin du fichier log4j.xml et qui va dans le fichier xml pour chercher les chemins des logs
extract_log_path_from_xml_file() {
	local service_name=$1
	local line=$(extract_log4jconfiguration_line "$service_name")
	local file=$(replace_service_name "$line" "$service_name")
	local lines=$(rechercher_logs_xml "$file")
	for line in ${lines[@]}; do
		extraire_chemin_log_xml "$line"
	done
}

# Fonction pour afficher un choix de service lors de la recherche
search_services_on_initd() {
	echo "Entrez le nom du service a rechercher:"
	read service_name

	result=$(ls /etc/init.d/ | grep -i "$service_name")

	if [ -z "$result" ]; then
		echo "Aucun service trouve pour '$service_name'."
		echo  -e "Essayez la commande 'locate nom_service | grep .log' \n"
	else
		echo "Services trouves:"
		echo "$result" | nl -w2 -s'. '
	fi
}
#Fonction pour afficher la taille d'un fichier
display_file_size() {
	local file=$1
	if [[ -e $file ]]; then
		size=$(du -h "$file" | cut -f1)
		echo "$file : $size"
	else
		echo "le fichier de log  n'existe pas."
	fi
}

# Fonction pour lancer la recherche de logs
launch_logs_finder() {
	search_services_on_initd

	if [ $(echo "$result" | wc -l) -eq 1 ]; then
		service_number=1
	else
		echo "Entrez le numero du service a choisir:"
		read service_number
	fi

	selected_service=$(echo "$result" | sed -n "${service_number}p")

	echo "Service selectionne: $selected_service"

	logs_files=()
	extracted_logs=$(extract_log_path_from_xml_file "$selected_service")
	service_logs=$(get_service_logs_directory "$selected_service")

	if [[ -n $extracted_logs ]]; then
		logs_files+=($(echo "$extracted_logs" | tr '\n' ' '))
	fi

	if [[ -n $service_logs ]]; then
		logs_files+=($(echo "$service_logs" | tr '\n' ' '))
	fi

	if [[ ${#logs_files[@]} -eq 0 ]]; then
		echo "Pas de fichier de logs trouve. Peut-etre '/var/log/$selected_service' "
	else
		echo "Repertoires de logs"
		if [[ ${logs_files[0]} == "Aucun" ]]; then
			echo "Aucun fichier de log trouve. Peut-etre '/var/log/$selected_service' "
		else
			for log in "${logs_files[@]}"; do
				echo "> $log"
			done
		fi
	fi

	echo -e "\nTailles du ou des fichiers de logs :"
	no_log_found=true
	for file in "${logs_files[@]}"; do
		if [[ -f $file ]]; then
			display_file_size "$file"
			no_log_found=false
		fi
	done

	PS3="Veuillez selectionner un fichier : "
	echo ""
	select file in "${logs_files[@]}"; do
		if [[ -n $file ]]; then
			if [[ -f $file ]]; then
				echo "Vous avez selectionne : $file"
				cat "$file" | tail -n 15
			fi
		else
			echo "Selection invalide. Veuillez reessayer."
		fi
		break
	done

	if $no_log_found; then
		echo "Aucun fichier de log trouve dans le script d'init."
	fi
}

