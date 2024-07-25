#!/bin/bash

SERVICE_NAME=BASE_ORACLE_via_LGPI_QUERY:info_produitsv2

display_http_code() {
	HTTP_CODE=$1

	case "$HTTP_CODE" in
	200) MSG="SUCCESS" ;;
	000) MSG="Connexion expiree ou autre erreur" ;;
	400) MSG="Mauvaise Requete" ;;
	401) MSG="Non Autorise" ;;
	403) MSG="Interdit" ;;
	404) MSG="Non Trouve" ;;
	500) MSG="Erreur Interne du Serveur" ;;
	502) MSG="Mauvaise Passerelle" ;;
	503) MSG="Service Indisponible" ;;
	504) MSG="Expiration de la Passerelle" ;;
	*) MSG="Code HTTP Inattendu" ;;

	esac
	echo "$SERVICE_NAME: HTTP $HTTP_CODE - $MSG"
}

check_http_status() {
	HTTP_CODE=$(curl -u test:emu -o /dev/null -s -w "%{http_code}" --connect-timeout 1 http://localhost:8082/lgpi.query/rest/v2/produit/info/code/3400932320189)
	echo "$HTTP_CODE"
}

HTTP_CODE=$(check_http_status)
# Fonction pour executer la sonde si l'uptime est superieur a 15 minutes
display_http_code $HTTP_CODE
