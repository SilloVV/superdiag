#!/bin/sh

# Charger les scripts a tester
if [ -f "../../main/bash/superdiag/rechercher_logs.sh" ]; then
	source "../../main/bash/superdiag/rechercher_logs.sh"
elif [[ -f "$(dirname "$0")/../../main/bash/superdiag/rechercher_logs.sh" ]]; then
        source "$(dirname "$0")/../../main/bash/superdiag/rechercher_logs.sh"
else
	echo "Le fichier rechercher_logs.sh est introuvable."
	exit 1
fi

test_replace_service_name_Given_SERVICE_variable__Return_service_name() {

	path="/var/log/\$SERVICE"
	service_name="lgpi_kernel"
	expected_result="/var/log/lgpi_kernel"

	output=$(replace_service_name $path $service_name)
	assertEquals "ne remplace pas la variable \$SERVICE par le nom du service" "$expected_result" "$output"

}

test_replace_service_name_Given_several_SERVICE_variable__Return_service_names() {

	path="/var/log/\$SERVICE/\$SERVICE.log"
	service_name="lgpi_kernel"
	expected_result="/var/log/lgpi_kernel/lgpi_kernel.log"

	output=$(replace_service_name $path $service_name)
	assertEquals "ne remplace pas les variables \$SERVICE par le nom du service" "$expected_result" "$output"

}

test_replace_service_name_Given_service_name__Return_service_name() {

	path="/var/log/lgpi_kernel"
	expected_result="/var/log/lgpi_kernel"

	output=$(replace_service_name $path $service_name)
	assertEquals " le test doit retourner le chemin complet, la methode est appelee sans variable" "$expected_result" "$output"
}

test_extract_log_directory_from_file_with_valid_log_path_return_log_path() {

	local test_file=$(mktemp)
	echo "INFO 2024-06-07 12:34:56 Some log message /var/log/service_test.log and more text" >"$test_file"

	local result=$(extract_log_directory_from_file "$test_file")
	assertEquals "doit retourner le chemin vers les fichiers de logs" "/var/log/service_test.log" "$result"

	rm "$test_file"
}

test_rechercher_logs_xml_Given_xml_file_Return_log_path_line_in_xml() {

	local testfile="test.xml"
	echo '<param name="file" value="/var/log/test.log" />' >$testfile

	result=$(rechercher_logs_xml "$testfile")
	assertContains "Doit retourner la ligne contenant le chemin des logs du fichier xml" "$result" '<param name="file" value="/var/log/test.log" />'

	rm $testfile
}

test_extraire_chemin_log_xml_Given_xml_log_path_line_return_log_path() {

	local line='<param name="file" value="/var/log/test.log" />'

	result=$(extraire_chemin_log_xml "$line")
	assertEquals "Doit retourner uniquement le chemin des logs " "$result" "/var/log/test.log"
}

test_replace_LOG_DIR_variable__Given_log_dir_Return_log_dir() {

	local service_name="test_service"
	local temp_init_script="/tmp/test_init_script"

	cat <<EOL >"$temp_init_script"
LOG_DIR=/var/log/\$SERVICE
LOG=\$LOG_DIR/dp.log
EOL

	local expected_log_file="/var/log/test_service/dp.log"
	local result=$(replace_LOG_DIR_variable "$service_name" "$temp_init_script")

	assertEquals "La variable LOG_DIR doit etre correctement remplacee" "$expected_log_file" "$result"

	rm -f "$temp_init_script"

}


#Chargement de shunit2
if [[ -f "$(dirname "$0")/../resources/shunit2" ]]; then
        .  "$(dirname "$0")/../resources/shunit2"
elif [[ -f "../../resources/shunit2" ]]; then
        . "../../resources/shunit2"
elif [[ -f "../resources/shunit2" ]]; then
        . "../resources/shunit2"
else
        echo "shunit2 introuvable"
fi

