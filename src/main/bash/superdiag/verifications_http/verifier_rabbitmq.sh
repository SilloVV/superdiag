#!/bin/bash

SERVICE_NAME=RabbitMQ

display_http_code() {
	HTTP_CODE=$1
	case "$HTTP_CODE" in
	200) MSG="SUCCESS" ;;
	000) MSG="Connexion expiree ou autre erreur" ;;
	400) MSG="Mauvaise Requête" ;;
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
	# Variables
	RABBITMQ_USER="lgpi"
	RABBITMQ_PASSWORD="3iD_K;4s"
	RABBITMQ_HOST="localhost"
	RABBITMQ_PORT="15672"

	# URL de l'API de gestion
	API_URL="http://${RABBITMQ_USER}:${RABBITMQ_PASSWORD}@${RABBITMQ_HOST}:${RABBITMQ_PORT}/#"

	# Execute la requête curl et capture la sortie
	HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" --connect-timeout 1 $API_URL)
	echo "$HTTP_CODE"
}

HTTP_CODE=$(check_http_status)
display_http_code $HTTP_CODE
