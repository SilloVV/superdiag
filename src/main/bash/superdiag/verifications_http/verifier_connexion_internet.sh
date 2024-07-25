#!/bin/bash

# Adresse a pinger
PING_ADDRESS="google.com"

# Nombre de paquets ping envoyes
PING_COUNT=4

# Effectuer le ping
ping -c $PING_COUNT $PING_ADDRESS > /dev/null 2>&1

# Verifier si le ping a reussi
if [ $? -eq 0 ]; then
  echo "PING: google.com SUCCESS"
else
  echo "PING: google.com FAIL- Verifiez la connexion internet  "
fi

