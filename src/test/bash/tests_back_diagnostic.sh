#!/bin/bash

#Dependance
if [[ -f "../../main/bash/superdiag/back_diagnostic.sh" ]]; then
	source "../../main/bash/superdiag/back_diagnostic.sh"
elif [[ -f "$(dirname "$0")/../../main/bash/superdiag/back_diagnostic.sh" ]]; then
	source "$(dirname "$0")/../../main/bash/superdiag/back_diagnostic.sh"
else
	echo "Le fichier back_diagnostic.sh est introuvable"
fi

setUp() {
    # Reinitialiser les variables globales pour chaque test pour garantir un etat propre
    nb_green=0
    nb_yellow=0
    nb_red=0
    nb_blue=0
    nb_orange=0

    green_services=()
    yellow_services=()
    red_services=()
    blue_services=()
    orange_services=()
    rebootable_services=()
    down_services=()
}

tearDown() {
    # Supprimer le fichier statut_global.txt s'il existe
    if [ -f statut_global.txt ]; then
        rm statut_global.txt
    fi

    return 0
}
test_GIVEN_active_services_WHEN_fill_services_lists_THEN_green_services_incremented() {
    fill_services_lists "active" "running" "service1"
    fill_services_lists "active" "running" "service2"
    assertEquals 2 ${#green_services[@]}
    assertEquals 2 $nb_green
    assertEquals "service1 active running" "${green_services[0]}"
    assertEquals "service2 active running" "${green_services[1]}"
}

test_GIVEN_exited_services_WHEN_fill_services_lists_THEN_yellow_services_incremented() {
    fill_services_lists "inactive" "exited" "service3"
    fill_services_lists "inactive" "exited" "service4"
    assertEquals 2 ${#yellow_services[@]}
    assertEquals 2 $nb_yellow
    assertEquals "service3 inactive exited" "${yellow_services[0]}"
    assertEquals "service4 inactive exited" "${yellow_services[1]}"
}

test_GIVEN_unknown_services_WHEN_fill_services_lists_THEN_blue_services_incremented() {
    fill_services_lists "unknown" "unknown" "service5"
    fill_services_lists "unknown" "unknown" "service6"
    assertEquals 2 ${#blue_services[@]}
    assertEquals 2 $nb_blue
    assertEquals "service5 unknown unknown" "${blue_services[0]}"
    assertEquals "service6 unknown unknown" "${blue_services[1]}"
}

test_GIVEN_inactive_services_WHEN_fill_services_lists_THEN_orange_services_and_down_services_incremented() {
    fill_services_lists "inactive" "stopped" "service7"
    fill_services_lists "inactive" "stopped" "service8"
    assertEquals 2 ${#orange_services[@]}
    assertEquals 2 $nb_orange
    assertEquals "service7 inactive stopped" "${orange_services[0]}"
    assertEquals "service8 inactive stopped" "${orange_services[1]}"
    assertEquals 2 ${#down_services[@]}
    assertEquals "service7" "${down_services[0]}"
    assertEquals "service8" "${down_services[1]}"
}

test_GIVEN_failed_services_WHEN_fill_services_lists_THEN_red_services_and_down_services_incremented() {
    fill_services_lists "failed" "failed" "service9"
    fill_services_lists "failed" "failed" "service10"
    assertEquals 2 ${#red_services[@]}
    assertEquals 2 $nb_red
    assertEquals "service9 failed failed" "${red_services[0]}"
    assertEquals "service10 failed failed" "${red_services[1]}"
    assertEquals 2 ${#down_services[@]}
    assertEquals "service9" "${down_services[0]}"
    assertEquals "service10" "${down_services[1]}"
}

test_GIVEN_active_service_WHEN_fill_services_lists_THEN_green_services_updated() {
    fill_services_lists "active" "running" "service1"
    assertEquals 1 ${#green_services[@]}
    assertEquals 1 $nb_green
    assertEquals "service1 active running" "${green_services[0]}"
}

test_GIVEN_exited_service_WHEN_fill_services_lists_THEN_yellow_services_updated() {
    fill_services_lists "inactive" "exited" "service2"
    assertEquals 1 ${#yellow_services[@]}
    assertEquals 1 $nb_yellow
    assertEquals "service2 inactive exited" "${yellow_services[0]}"
}

test_GIVEN_unknown_service_WHEN_fill_services_lists_THEN_blue_services_updated() {
    fill_services_lists "unknown" "unknown" "service3"
    assertEquals 1 ${#blue_services[@]}
    assertEquals 1 $nb_blue
    assertEquals "service3 unknown unknown" "${blue_services[0]}"
}

test_GIVEN_inactive_service_WHEN_fill_services_lists_THEN_orange_services_and_down_services_updated() {
    fill_services_lists "inactive" "stopped" "service4"
    assertEquals 1 ${#orange_services[@]}
    assertEquals 1 $nb_orange
    assertEquals "service4 inactive stopped" "${orange_services[0]}"
    assertEquals 1 ${#down_services[@]}
    assertEquals "service4" "${down_services[0]}"
}

test_GIVEN_failed_service_WHEN_fill_services_lists_THEN_red_services_and_down_services_updated() {
    fill_services_lists "failed" "failed" "service5"
    assertEquals 1 ${#red_services[@]}
    assertEquals 1 $nb_red
    assertEquals "service5 failed failed" "${red_services[0]}"
    assertEquals 1 ${#down_services[@]}
    assertEquals "service5" "${down_services[0]}"
}

test_GIVEN_no_down_services_WHEN_update_global_status_THEN_statut_global_is_0() {
    down_services=()
    update_global_status "${down_services[@]}"
    assertTrue "[ -f statut_global.txt ]"
    assertEquals "0" "$(cat statut_global.txt)"
}

test_GIVEN_down_services_WHEN_update_global_status_THEN_statut_global_is_1() {
    down_services=("service3")
    update_global_status "${down_services[@]}"
    assertTrue "[ -f statut_global.txt ]"
    assertEquals "1" "$(cat statut_global.txt)"
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

