#!/bin/bash

# Definition des couleurs
BLEU="\e[1;36m"    #services inconnus par systemctl
RESETCOLOR="\e[0m" #couleur par defaut


#Fonctins pour lancer les verifications https
lancer_verifications_http() {
	for script in "/home/pharmagest/superdiag/verifications_http/"*.sh; do
		script_name=$(basename "$script")
		if [[ "$script_name" == "all_verifications.sh" || "$script_name" == "verifier_hotes_salt.sh" ]]; then
			continue
		fi

		if [[ -f "$script" && -x "$script" ]]; then
			"$script"
		else
			echo "Le script $script n'est pas executable ou n'existe pas"
		fi
	done
}

echo -e "\n${BLEU}========================================================================================${RESETCOLOR}"
echo -e "${BLEU}                                    TESTS HTTP ${RESETCOLOR}\n"
lancer_verifications_http
echo -e "\n${BLEU}========================================================================================${RESETCOLOR}"
