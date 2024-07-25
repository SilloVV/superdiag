#!/bin/bash

# Liste de services pour l'outil de diagnostic
SERVICES_DIAG=( "agenda" "automate_com" "bcb" "birt" "cobweb" "dmp" "dp-core" "epson_devicecontrollogserviced" "epson_pcsvcd" "fmd-engine" "fmd_jms" "insi-engine" "jetty" "jexec" "lgo-jwt" "lgo_muse" "lgo-splunk" "lgpi_axel" "lgpi_automate_listener" "lgpi_commande_auto" "lgpi_flux" "lgpi_hermes" "lgpi_igcs" "lgpi_imprime" "lgpi_kernel" "lgpi_ldp" "lgpi_migration_ged" "lgpi_network" "lgpi_notifications_poller" "lgpi_officentral" "lgpi_offichat" "lgpi_offilink" "lgpi_offilive" "lgpi_opentty" "lgpi_pharmassl" "lgpi_placedisque" "lgpi_placedisque" "lgpi_prg_relationnel" "lgpi_query" "lgpi_release_notes" "lgpi_sarex" "lgpi_securisation" "lgpi_spooldev" "lgpi_swapoff" "lgpi_verrou_cmde" "lgpi_vnc99" "lso_jms" "mercure" "mmr" "mobile-sale-service" "moteursv-convention" "moteursv-lecteur" "moteursv-patient"  "network" "nf525" "nf525_creation_ticket" "nf525_jet" "offilink" "offipos" "offireport" "offiseen_listener" "oracle_base" "oracle_bi" "oracle_listener" "oracle_report10g" "splunk" "stereo-client" "ulysse-client" "vitale-connect" ) 


#Liste des services pour l'outil de supervision
SERVICES_SUPER=("birt" "lgpi_verrou_cmde" "lgo_muse" "lgpi_query" "rabbitmq-server" "oracle_base" "vitale-connect" "automate_com" "lgpi_commande_auto")

# Fonction check_status : trouver l'etat d'un service
check_status() {
	local service_name="$1"
	local status=$(systemctl show "$service_name" | grep ActiveState | awk -F= '{print $2}')

	# Verifier si le service est vraiment inactif ou bien inconnu
	if [[ $status == "inactive" || $status == "failed" ]]; then
		local service_status_output=$(service "$service_name" status)
		if [[ $service_status_output == *"is running"* || $service_status_output == *"semble d"* || $service_status_output == *"est actif"* ]]; then
			status="active"
		else
			local is_active=$(systemctl is-active "$service_name")
			if [[ $is_active == "unknown" ]]; then
				status="unknown"
			fi
		fi
	fi

	echo "$status"
}

# Liste des services a verifier
services_to_check=("${SERVICES_DIAG[@]}")
services_to_supervise=("${SERVICES_SUPER[@]}")
