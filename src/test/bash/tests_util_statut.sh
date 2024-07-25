#!/bin/bash

#Dependances
if [[ -f "../../main/bash/superdiag/util_statut.sh" ]]; then
        source "../../main/bash/superdiag/util_statut.sh"
elif [[ -f "$(dirname "$0")/../../main/bash/superdiag/util_statut.sh" ]]; then
        source "$(dirname "$0")/../../main/bash/superdiag/util_statut.sh"
else
        echo "Le fichier util_statut.sh est introuvable"
fi


if [[ -f "./mock.sh" ]]; then
        source "./mock.sh"
elif [[ -f "$(dirname "$0")/mock.sh" ]]; then
        source "$(dirname "$0")/mock.sh"
else
        echo "Le fichier mock.sh est introuvable"
fi



test_check_status_GIVEN_birt_is_reported_inactive_WHEN_checking_status_THEN_should_be_active() {
    # Test pour birt (inactive mais en réalité actif)
    local result=$(check_status "birt")
    assertEquals "active" "$result"
}

test_check_status_GIVEN_lgpi_verrou_cmde_is_reported_failed_WHEN_checking_status_THEN_should_be_active() {
    # Test pour lgpi_verrou_cmde (failed mais en réalité actif)
    local result=$(check_status "lgpi_verrou_cmde")
    assertEquals "active" "$result"
}

test_check_status_GIVEN_lgo_muse_is_active_WHEN_checking_status_THEN_should_be_active() {
    # Test pour lgo_muse (actif)
    local result=$(check_status "lgo_muse")
    assertEquals "active" "$result"
}

test_check_status_GIVEN_lgpi_query_is_reported_inactive_WHEN_checking_status_THEN_should_be_inactive() {
    # Test pour lgpi_query (inactive et vraiment inactif)
    local result=$(check_status "lgpi_query")
    assertEquals "inactive" "$result"
}

test_check_status_GIVEN_rabbitmq_server_is_reported_inactive_WHEN_checking_status_THEN_should_be_inactive() {
    # Test pour rabbitmq-server (inactive et vraiment inactif)
    local result=$(check_status "rabbitmq-server")
    assertEquals "inactive" "$result"
}

test_check_status_GIVEN_oracle_base_is_reported_failed_WHEN_checking_status_THEN_should_be_active() {
    # Test pour oracle_base (failed mais en réalité actif)
    local result=$(check_status "oracle_base")
    assertEquals "active" "$result"
}

test_check_status_GIVEN_vitale_connect_is_reported_inactive_WHEN_checking_status_THEN_should_be_inactive() {
    # Test pour vitale-connect (inactive et vraiment inactif)
    local result=$(check_status "vitale-connect")
    assertEquals "inactive" "$result"
}

test_check_status_GIVEN_automate_com_is_active_WHEN_checking_status_THEN_should_be_active() {
    # Test pour automate_com (actif)
    local result=$(check_status "automate_com")
    assertEquals "active" "$result"
}

test_check_status_GIVEN_lgpi_commande_auto_is_reported_failed_WHEN_checking_status_THEN_should_be_active() {
    # Test pour lgpi_commande_auto (failed mais en réalité actif)
    local result=$(check_status "lgpi_commande_auto")
    assertEquals "active" "$result"
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

