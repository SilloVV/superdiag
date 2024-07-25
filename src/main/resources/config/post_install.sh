#!/bin/bash

# Alias a ajouter
new_alias="alias superdiag='(cd /home/pharmagest/superdiag && ./lancer_diagnostic.sh && cd -)'"

# Fichier .bashrc
bashrc_file=~/.bashrc


if ! grep -qF "$new_alias" "$bashrc_file"; then
    # Temporaire fichier pour stocker le resultat
    temp_file="$(mktemp)"

    # Trouve la derniere ligne contenant "alias" et ajoute la nouvelle ligne apres
    awk -v new_alias="$new_alias" '
        /^alias/ { last_alias=NR }
        { lines[NR] = $0 }
        END {
            for (i=1; i<=NR; i++) {
                print lines[i]
                if (i == last_alias) {
                    print new_alias
                }
            }
            if (!last_alias) {
                print new_alias
            }
        }
    ' "$bashrc_file" > "$temp_file"

    # Remplace le fichier .bashrc par le fichier temporaire
    mv "$temp_file" "$bashrc_file"

    # Sourcing .bashrc
    source $bashrc_file
fi
