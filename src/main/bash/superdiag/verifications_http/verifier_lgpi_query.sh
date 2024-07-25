#!/bin/bash

SERVICE_NAME=LGPI_QUERY

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
	HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" --connect-timeout 1 http://localhost/lgpi.query/)
	echo "$HTTP_CODE"
}

HTTP_CODE=$(check_http_status)
display_http_code $HTTP_CODE
