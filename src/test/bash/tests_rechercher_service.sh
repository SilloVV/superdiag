#!/bin/bash

#Dependances
if [[ -f "../../main/bash/superdiag/rechercher_service.sh" ]]; then
        source "../../main/bash/superdiag/rechercher_service.sh"
elif [[ -f "$(dirname "$0")/../../main/bash/superdiag/rechercher_service.sh" ]]; then
        source "$(dirname "$0")/../../main/bash/superdiag/rechercher_service.sh"
else
        echo "Le fichier rechercher_service.sh est introuvable"
fi


if [[ -f "./mock.sh" ]]; then
        source "./mock.sh"
elif [[ -f "$(dirname "$0")/mock.sh" ]]; then
        source "$(dirname "$0")/mock.sh"
else
        echo "Le fichier mock.sh est introuvable"
fi

test_search_services_on_systemctl_Given_Execution_When_Called_Then_PromptUserForInput() {

	output=$(search_services_on_systemctl <<<"" 2>&1)
	assertContains "$output" "Entrez le nom du service a rechercher:"
}

test_search_services_on_systemctl_Given_knownService_Return_services_trouves() {

	output=$(search_services_on_systemctl <<<"lgpi")
	assertContains "$output" "lgpi"

}

test_search_services_on_systemcl_Given_Service_aegfahohefaerhgpaerh64616465_Return_AucunServiceTrouve() {

	output=$(search_services_on_systemctl <<<"aegfahohefaerhgpaerh64616465")
	assertContains "$output" "Aucun service trouve pour 'aegfahohefaerhgpaerh64616465'."

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

