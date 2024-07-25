#!/bin/bash

# Verifier si ncdu est installe
if ! command -v ncdu &>/dev/null; then
	echo "ncdu n'est pas installe. Installation en cours..."

	# Utiliser yum pour installer ncdu
	sudo yum install -y ncdu

	echo "ncdu a ete installe avec succes."
else
	echo "ncdu est deja installe."
fi

# Proposer a l'utilisateur d'analyser /var/log ou un autre repertoire
echo "Quel repertoire voulez-vous analyser ?"
echo "1. /var/log"
echo "2. /home/oracle/oradata/PHAL1"
echo "3. Specifier un autre repertoire"
read -p "Entrez le numero correspondant a votre choix: " choix

case "$choix" in
1)
	repertoire="/var/log"
	;;
2)
	repertoire="/home/oracle/oradata/"
	;;
3)
	echo "Entrez le chemin du repertoire a analyser avec ncdu:"
	read -e -p "Chemin: " repertoire
	;;
*)
	echo "Choix invalide."
	exit 1
	;;
esac

# Verifier si le repertoire existe
if [ -d "$repertoire" ]; then
	echo "Analyse du repertoire $repertoire avec ncdu..."
	ncdu "$repertoire"
else
	echo "Erreur: Le repertoire $repertoire n'existe pas."
	exit 1
fi
