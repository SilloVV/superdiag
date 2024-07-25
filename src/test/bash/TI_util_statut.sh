#!/bin/bash

# Charger les scripts a tester
if [ -f "../../main/bash/superdiag/util_statut.sh" ]; then
	source "../../main/bash/superdiag/util_statut.sh"
else
	echo "Le fichier util_statut.sh est introuvable."
	exit 1
fi

test_check_status_Given_lgpi_query_Return_etat() {

	result=$(check_status "lgpi_query")
	assertNotNull "etat du service lgpi_query est non null" "$result"
}

test_check_status_Given_lgpi_query_Return_etat() {

	result=$(check_status "dshgorjgdq")
	assertEquals "etat du service lgpi_query est inconnu" "unknown" "$result"
}

# charge ShUnit2
. ../resources/shunit2