#!/bin/bash

#ceci est une trame exemple d'un script de test pour qu'il puissêtre correctemnt executé via Jekins 
#le nom du script de test doit commencer par "tests_" pour qu'il soit bien lancé par Jenins

# Mock de la commande systemctl
systemctl() {
    case "$1" in
        show)
            case "$2" in
                birt) echo "ActiveState=inactive" ;;
                lgpi_verrou_cmde) echo "ActiveState=failed" ;;
                lgo_muse) echo "ActiveState=active" ;;
                lgpi_query) echo "ActiveState=inactive" ;;
                rabbitmq-server) echo "ActiveState=inactive" ;;
                oracle_base) echo "ActiveState=failed" ;;
                vitale-connect) echo "ActiveState=inactive" ;;
                automate_com) echo "ActiveState=active" ;;
                lgpi_commande_auto) echo "ActiveState=failed" ;;
                *) echo "ActiveState=inactive" ;;
            esac
            ;;
        is-active)
            if [[ "$2" == "lgpi_verrou_cmde" || "$2" == "oracle_base" || "$2" == "lgpi_commande_auto" ]]; then
                echo "unknown"
            else
                echo "active"
            fi
            ;;
        *)
            echo "Unknown command"
            ;;
    esac
}

# Mock de la commande service
service() {
    case "$1" in
        birt) echo "$1 is running" ;;
        lgpi_verrou_cmde) echo "$1 est inactif mais semble démarrer correctement" ;;
        lgpi_query) echo "$1 is not running" ;;
        rabbitmq-server) echo "$1 is not running" ;;
        oracle_base) echo "$1 est inactif mais semble démarrer correctement" ;;
        vitale-connect) echo "$1 is not running" ;;
        *) echo "$1 is running" ;;
    esac
}
