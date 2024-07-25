#!/bin/bash

#Dependances
if [[ -f "../../main/bash/superdiag/afficher_couches.sh" ]]; then
        source "../../main/bash/superdiag/afficher_couches.sh"
elif [[ -f "$(dirname "$0")/../../main/bash/superdiag/afficher_couches.sh" ]]; then
        source "$(dirname "$0")/../../main/bash/superdiag/afficher_couches.sh"
else
        echo "Le fichier afficher_couches.sh est introuvable"
fi


if [[ -f "./mock.sh" ]]; then
        source "./mock.sh"
elif [[ -f "$(dirname "$0")/mock.sh" ]]; then
        source "$(dirname "$0")/mock.sh"
else
        echo "Le fichier mock.sh est introuvable"
fi


test_extract_name_and_layer_of_services_Given_ServiceAndLayerUnknown_Return_null() {

	result=$(extract_name_and_layer_of_services)
	assertNotContains "Le nom du service et la couche doivent etre inconnus" "$result" "99:unknownservice"
}

test_get_service_description_Given_notaservice_Return_null() {

	service_name="gezgg6a4g5"
	expected_result=""

	output=$(get_service_description $service_name)
	assertEquals "recupere la description d'un service inconnu" "$expected_result" "$output"

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

