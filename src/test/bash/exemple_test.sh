#!/bin/bash

#ceci est une trame exemple d'un script de test pour qu'il puissêtre correctemnt executé via Jekins 
#le nom du script de test doit commencer par "tests_" pour qu'il soit bien lancé par Jenins

#Dependance
if [[ -f "../../main/bash/superdiag/script_a_tester.sh" ]]; then
        source "../../main/bash/superdiag/script_a_tester.sh"
elif [[ -f "$(dirname "$0")/../../main/bash/superdiag/script_a_tester.sh" ]]; then
        source "$(dirname "$0")/../../main/bash/superdiag/script_a_tester.sh"
else
        echo "Le fichier script_a_tester.sh est introuvable"
fi

test_exemple() {
    assertEquals "1" "1"
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


