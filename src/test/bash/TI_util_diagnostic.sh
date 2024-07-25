#!/bin/bash

# Charger les scripts a tester
if [ -f "../../main/bash/superdiag/util_diagnostic.sh" ]; then
	source "../../main/bash/superdiag/util_diagnostic.sh"
else
	echo "Le fichier util_diagnostic.sh est introuvable."
	exit 1
fi

test_check_status_Given_notincheckedservices_but_inLinuxservices_return_Service_notfound() {

	result=$(check_status_in_list "systemd")
	assertEquals "La methode ne retourne pas Service non trouve" "$result" "Service non trouve: systemd"

}

test_service_in_checked_list_Given_service_in_checked_return_0() {

	result="$(service_in_checked_list rabbitmq-server)"
	assertEquals "La methode doit retourner 0" "0" "$?"

}

test_service_in_checked_list_Given_service_not_in_checked_return1() {

	result="$(service_in_checked_list inconnu)"
	assertEquals "La methode doit retourner 1" "1" "$?"
}

test_check_substatus_Given_lgpi_kernel_Return_sous_etat() {

	result=$(check_substatus "lgpi_kernel")
	assertNotNull "sous-etat du service lgpi_kernel doit etre non null" "$result"

}

test_check_substatus_Given_not_in_checked_list_Return_unknown() {

	result=$(check_substatus "64df654zefsdfqsfd")
	assertEquals "service normalement inconnu:" "unknown" "$result"

}

# charge ShUnit2
. ../resources/shunit2
