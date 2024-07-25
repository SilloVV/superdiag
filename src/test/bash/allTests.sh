#!/bin/bash

# Definir le repertoire contenant les fichiers de tests

if [[ -d "../bash/" ]]; then
	TEST_DIR="../bash/"
elif [[ -d "$(dirname "$0")/" ]]; then
	TEST_DIR="$(dirname "$0")/"
else
        echo "Le repertoire bash est introuvable"
fi

# Executer tous les fichiers de tests dans le repertoire
for test_file in "$TEST_DIR"tests_*.sh; do
	if [ -f "$test_file" ]; then
		bash "$test_file"
		if [ $? -ne 0 ]; then
			echo "$test_file a echoue."
		fi
	fi
done
