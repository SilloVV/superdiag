#!/bin/bash

# Charger les scripts a tester
source "$(dirname "$0")/60-check-status-changes.sh"

#Test des fonctions de la sonde (ecriture , modification du fichier txt)

test_write_statuses_in_file_given_services_to_check_when_write_then_file_contains_lgpi_query_status() {
	is_status_found=false
	file_path="test_write_statuses_in_file.txt"

	write_statuses_in_file $file_path

	actual_content=$(cat "$file_path")
	if echo "$actual_content" | grep -q "lgpi_query : active : 0"; then
		is_status_found=true
	elif echo "$actual_content" | grep -q "lgpi_query : inactive : 0"; then
		is_status_found=true
	elif echo "$actual_content" | grep -q "lgpi_query : failed : 0"; then
		is_status_found=true
	fi

	assertTrue "Le fichier devrait contenir le statut de lgpi_query avec 'active', 'inactive' ou 'failed'" $is_status_found
}

test_write_statuses_in_file_given_services_to_check_when_write_then_file_contains_lgpi_query_status() {
	is_status_found=false
	file_path="test_write_statuses_in_file.txt"

	write_statuses_in_file "$file_path"

	actual_content=$(cat "$file_path")
	if echo "$actual_content" | grep -q "lgpi_query : active : 0"; then
		is_status_found=true
	elif echo "$actual_content" | grep -q "lgpi_query : inactive : 0"; then
		is_status_found=true
	elif echo "$actual_content" | grep -q "lgpi_query : failed : 0"; then
		is_status_found=true
	fi

	assertTrue "Le fichier devrait contenir le statut de lgpi_query avec 'active', 'inactive' ou 'failed'" $is_status_found

	rm -f "$file_path"
}

test_write_statuses_in_file_given_services_to_check_when_write_then_file_contains_all_services() {
	file_path="test_write_statuses_in_file.txt"
	write_statuses_in_file "$file_path"

	actual_content=$(cat "$file_path")

	for service in "${services_to_check[@]}"; do
		if ! echo "$actual_content" | grep -q "$service : "; then
			fail "Le fichier de statut ne contient pas le service attendu : $service"
			rm -f "$file_path"
			return 1
		fi
	done

	assertTrue "Tous les services devraient être presents dans le fichier de statut" 0
	rm -f "$file_path"
}

test_write_statuses_in_file_given_services_to_check_when_write_then_file_contains_all_statuses() {
	file_path="test_write_statuses_in_file.txt"
	write_statuses_in_file "$file_path"

	actual_content=$(cat "$file_path")

	for service in "${services_to_check[@]}"; do
		if ! echo "$actual_content" | grep -q "$service : active" && ! echo "$actual_content" | grep -q "$service : inactive" && ! echo "$actual_content" | grep -q "$service : failed" && ! echo "$actual_content" | grep -q "$service : unknown"; then
			fail "Le fichier de statut ne contient pas le status attendu pour : $service"
			rm -f "$file_path"
			return 1
		fi
	done

	assertTrue "Tous les services devraient être presents dans le fichier de statut avec un statut associe" 0
	rm -f "$file_path"
}

test_write_statuses_in_file_given_services_to_check_when_write_then_file_contains_all_counters() {
	file_path="test_write_statuses_in_file.txt"
	write_statuses_in_file "$file_path"

	actual_content=$(cat "$file_path")

	for service in "${services_to_check[@]}"; do
		if ! echo "$actual_content" | grep -qE ": [0-9]+"; then
			fail "Le fichier de statut ne contient pas le compteur attendu pour : $service"
			rm -f "$file_path"
			return 1
		fi
	done

	assertTrue "Tous les services devraient être presents dans le fichier de statut avec un compteur associe" 0
	rm -f "$file_path"
}

test_call_write_statuses_in_file_if_void_file_Given_FileEmpty_When_Called_Then_FunctionCalled() {

	test_file="test_statuts_precedent.txt"
	touch "$test_file"

	call_write_statuses_in_file_if_void_file "$test_file"
	result=$?

	assertEquals "write_statuses_in_file doit etre appele pour un fichier vide" "0" "$result"

	rm $test_file
}

test_call_write_statuses_in_file_if_void_file_Given_FileNotEmpty_When_Called_Then_FunctionNotCalled() {

	test_file="test_statuts_prec.txt"
	echo "some content" >"$test_file"

	call_write_statuses_in_file_if_void_file "$test_file"
	result=$?

	assertEquals "write_statuses_in_file ne doit pas etre appele pour un fichier non vide" "2" "$result"

	rm $test_file
}

test_create_file_if_not_existing_Given_FileExists_When_Called_Then_FileNotRecreated() {

	test_file="test_statuts_prec.txt"
	touch "$test_file"
	local original_mod_time
	original_mod_time=$(stat -c %Y "$test_file")

	create_file_if_not_existing "$test_file"
	local new_mod_time
	new_mod_time=$(stat -c %Y "$test_file")

	assertEquals "L'heure et la date de modification du fichier ne doit pas changer" "$original_mod_time" "$new_mod_time"
	rm $test_file
}

test_create_file_if_not_existing_Given_FileNotExists_When_Called_Then_FileCreated() {

	test_file="test_statuts_prec.txt"
	create_file_if_not_existing "$test_file"

	assertTrue "File was not created" "[ -f \"$test_file\" ]"

	rm $test_file
	echo "fichier supprime"
}

test_initialize_prev_status_in_array_given_valid_file_when_initialize_then_statuses_and_counters_are_populated() {

	local test_file="test_statuts_prec.txt"
	echo -e "service1 : status1 : 1\nservice2 : status2 : 2" >"$test_file"

	initialize_prev_status_in_array "$test_file"

	assertEquals "status1" "${saved_statuses["service1"]}"
	assertEquals "status2" "${saved_statuses["service2"]}"
	assertEquals "1" "${compteurs["service1"]}"
	assertEquals "2" "${compteurs["service2"]}"

	rm "$test_file"
}

test_initialize_current_status_in_array_given_services_when_checked_then_current_statuses_are_populated() {
	# services_to_check=("lgpi_query" "lgpi_swapoff")

	initialize_current_status_in_array

	assertEquals "active" "${current_statuses["lgpi_query"]}"
	assertEquals "active" "${current_statuses["lgo_muse"]}"
}

test_compare_statuses_active_to_inactive() {
	file_path="test_statuts_prev.txt"
	echo "lgpi_query : active : 0" >"$file_path"

	initialize_prev_status_in_array "$file_path"
	initialize_current_status_in_array

	current_statuses["lgpi_query"]="inactive"

	compare_statuses "$file_path" "$(declare -p current_statuses)" "$(declare -p saved_statuses)"

	assertEquals "Le compteur doit passer a 1 en passant a l'etat 'inactive'" "1" "${compteurs["lgpi_query"]}"

	rm -f "$file_path"
}

test_compare_statuses_inactive_to_inactive() {
	file_path="test_statuts_prev.txt"
	echo "lgpi_query : inactive : 1" >"$file_path"

	initialize_prev_status_in_array "$file_path"
	initialize_current_status_in_array

	current_statuses["lgpi_query"]="inactive"

	compare_statuses "$file_path" "$(declare -p current_statuses)" "$(declare -p saved_statuses)"

	assertEquals "Le compteur doit augmenter si l'etat reste 'inactive' " "2" "${compteurs["lgpi_query"]}"

	rm -f "$file_path"
}

test_compare_statuses_inactive_to_active() {
	file_path="test_statuts_prev.txt"
	echo "lgpi_query : inactive : 2" >"$file_path"

	initialize_prev_status_in_array "$file_path"

	current_statuses["lgpi_query"]="active"
	compare_statuses "$file_path" "$(declare -p current_statuses)" "$(declare -p saved_statuses)"

	assertEquals "Le compteur doit passer a 0 lorsque l'etat redevient 'active' " "0" "${compteurs["lgpi_query"]}"

	rm -f "$file_path"
}

test_compare_statuses_ko_to_ok() {
	file_path="test_statuts_prev.txt"
	echo "lgpi_query : inactive : 4" >"$file_path"

	initialize_prev_status_in_array "$file_path"

	current_statuses["lgpi_query"]="active"
	compare_statuses "$file_path" "$(declare -p current_statuses)" "$(declare -p saved_statuses)"

	assertEquals "Le compteur doit passer a 0 lorsque l'etat redevient 'active' " "0" "${compteurs["lgpi_query"]}"

	rm -f "$file_path"
}

test_compare_statuses_active_to_failed() {
	file_path="test_statuts_prev.txt"
	echo "lgpi_query : active : 0" >"$file_path"

	initialize_prev_status_in_array "$file_path"
	initialize_current_status_in_array

	current_statuses["lgpi_query"]="failed"

	compare_statuses "$file_path" "$(declare -p current_statuses)" "$(declare -p saved_statuses)"

	assertEquals "Le compteur doit passer a 1 en passant a l'etat 'failed'" "1" "${compteurs["lgpi_query"]}"

	rm -f "$file_path"
}

test_compare_statuses_failed_to_failed() {
	file_path="test_statuts_prev.txt"
	echo "lgpi_query : failed : 1" >"$file_path"

	initialize_prev_status_in_array "$file_path"
	initialize_current_status_in_array

	current_statuses["lgpi_query"]="failed"

	compare_statuses "$file_path" "$(declare -p current_statuses)" "$(declare -p saved_statuses)"

	assertEquals "Le compteur doit augmenter si l'etat reste 'failed' " "2" "${compteurs["lgpi_query"]}"

	rm -f "$file_path"
}

test_compare_statuses_failed_to_inactive() {
	file_path="test_statuts_prev.txt"
	echo "service_test : failed : 1" >"$file_path"

	initialize_prev_status_in_array "$file_path"
	initialize_current_status_in_array

	current_statuses["service_test"]="inactive"

	compare_statuses "$file_path" "$(declare -p current_statuses)" "$(declare -p saved_statuses)"

	assertEquals "Le compteur doit augmenter si l'etat passe de 'failed' a 'inactive' " "2" "${compteurs["service_test"]}"

	unset current_statuses["service_test"]
	unset saved_statuses["service_test"]
	unset compteurs["service_test"]
	rm -f "$file_path"
}

test_compare_statuses_inactive_to_failed() {
	file_path="test_statuts_prev.txt"
	echo "service_test : inactive : 1" >"$file_path"

	initialize_prev_status_in_array "$file_path"
	initialize_current_status_in_array

	current_statuses["service_test"]="failed"

	compare_statuses "$file_path" "$(declare -p current_statuses)" "$(declare -p saved_statuses)"

	assertEquals "Le compteur doit augmenter si l'etat passe de 'inactive' a  'failed' " "2" "${compteurs["service_test"]}"

	unset current_statuses["service_test"]
	unset saved_statuses["service_test"]
	unset compteurs["service_test"]
	rm -f "$file_path"

}

test_compare_statuses_failed_to_active() {
	file_path="test_statuts_prev.txt"
	echo "lgpi_query : failed : 1" >"$file_path"

	initialize_prev_status_in_array "$file_path"

	current_statuses["lgpi_query"]="active"
	compare_statuses "$file_path" "$(declare -p current_statuses)" "$(declare -p saved_statuses)"

	assertEquals "Le compteur doit passer a 0 lorsque l'etat redevient 'active' " "0" "${compteurs["lgpi_query"]}"

	rm -f "$file_path"
}

test_uptime_superior_to_15_minutes() {
	local uptime_output="11:03:27 up 0 days, 0:16, 1 user, load average: 0.44, 0.39, 0.26"
	total_minutes=$(check_uptime "$uptime_output")
	assertEquals 16 "$total_minutes"
}

test_uptime_inferior_or_equal_to_15_minutes() {
	local uptime_output="11:03:27 up 0 days, 0:15, 1 user, load average: 0.44, 0.39, 0.26"
	total_minutes=$(check_uptime "$uptime_output")
	assertEquals 15 "$total_minutes"
}

test_uptime_days_and_hours() {
	local uptime_output="11:03:27 up 1 day, 1:00, 1 user, load average: 0.44, 0.39, 0.26"
	total_minutes=$(check_uptime "$uptime_output")
	assertEquals 1500 "$total_minutes"
}

test_uptime_multiple_days() {
	local uptime_output="11:03:27 up 2 days, 0:00, 1 user, load average: 0.44, 0.39, 0.26"
	total_minutes=$(check_uptime "$uptime_output")
	assertEquals 2880 "$total_minutes"
}

# charge ShUnit2
.  "$(dirname "$0")/../../../test/resources/shunit2"
