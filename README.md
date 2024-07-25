# Superdiag

Superdiag est un outil deux en un qui permet de superviser le serveur des officines et de diagnostiquer un probleme sur le serveur sur le terrain, en qualification, phase de test ou encore lors du developpement d'une fonctionnalite.   
Cet outil est ecrit en Bourne hell et il est possible de le lancer via la commande 'superdiag' de n'importe ou sur le serveur !

## Installation
Superdiag est installe grace a un rpm disponible sur la branche master Jenkins du depot `superdiag`.   

## Utilisation
### Module 1 : outil de diagnostic   
### Lancement   
Une fois installe, il suffit de lancer la commande `superdiag`. C'est magique ! :)
### Fonctionnalites
#### Etats des services des listes disponibles en suivant ce lien -> 'https://agora.groupe.pharmagest.com/bitbucket/projects/LGO/repos/superdiag/browse/src/main/bash/superdiag/util_statut.sh#4'.   
- SERVICE_DIAG: liste des services verifies par l'outil de diagnostic    
- SERVICE_SUPER: liste des services verifies par l'outil de supervision    
#### Volumetrie des repertoires de logs:   
- taille du repertoire /var/log   
- 20 fichiers de logs les plus    
- 20 repertoires de logs les plus lourds     
#### Tests HTTP:    
- verification de code de retour de curls sur lgpi_query , info_produits_v2, birt et rabbitmq.   
#### Redemarrer un des services de la liste (commande 'systemctl restart')    
#### Rechercher un service:    
- donne l'etat et les dernieres lignes du journal de demarrage du service recherche .    
- le service recherche n'est pas forcement dans la liste du lien, la recherche concerne l'ensemble des services linux du serveur.    
#### Afficher les services en couches :    
- afficher sous forme de couches les services "Systeme cinq" present dans le rc5.d cinquieme couche de lancement linux)   
#### Trouver un repertoire de log:   
- permet de rechercher un service et le chemin de son ou ses fichiers de logs (utilise le fichier de configuration log4j.xml)    
- permet d'afficher les dernieres lignes du fichier de log selectionne   
#### Utilisation memoire/CPU:    
- affiche un ensemble de statistiques concernant l'espace memoire utilise, echange ou libre   
- affiche la main classe des processus java utilisant le plus de RAM ou de CPU    
- il est possible de rafraichir l'affichage (pour un suivi plus dynamique)    
#### Analyse memoire avec ncdu:   
- permet d'utiliser l'outil "ncdu" permettant de naviguer dans l'arborescence et de verifier la taille des repertoires et fichiers linux du serveur      
### Module 2 : outil de supervision 
L'outil de supervision est un ensemble de 3 tableaux de bords Splunk (ID. Delivery General, ID. Delivery en un coup d'oeil et ID.Delivery Specifique a un client) qui sont alimentes par les sondes 60 et 61 ainsi que par les sondes deja disponibles sur le rpm lgo-probes dans le repertoire probes.d.
#### Tableau de bord : ID. Delivery en un coup d'oeil 
Ce tableau de bord permet comme son nom l'indique d'avoir une vue rapide sur les Clients qui ont un ou plusieurs services KO.    
En cliquant sur une ligne de resultat , une redirection est faite sur le tableau de bprd `ID.Delivery Specifique a un client` avec le CIP pre-rempli.
#### Tableau de bord : ID. Delivery Specifique a un client
Ce tableau permet d'avoir plus d'information pour un client via son CIP sans avoir a faire de telemaintenance.
- Informations concernant le clients (version LGPI, Agence, Derniere mise a jour...)
- Informations concernant l'espace memoire de ce client (Espace RAM, Espace disque )
- Informations concernant les services en officines (quels services sont tombes pendant plus de ...h et quand)
#### Tableau de bord : ID. Delivery General   
Ce tableau de bord permet d'avoir des informations sur les serveurs des officines de façon plus generale.    
- Informations concernant L'espace memoire RAM et disque (tous les utilisateurs ayant moins de seuil% d'espace diponible)
- Informations concernant l'etat des services en officine 
### Architecture
- Page confluence -> 'https://agora.groupe.pharmagest.com/confluence/pages/viewpage.action?pageId=300418164'
### Fonctionnement du build et des tests post build.
Le build est lance via gradle et les parametres de build sont definis dans le fichier build.gradle.  
Les etapes de builds sont choisissables dans le Jenkinsfile.   
L'ensemble des tests et ressources de tests sont places dans le repertoire `src/test/`.
Les tests unitaires sont lances grace a un fichier nomme `allTest.sh` qui lance tous les scripts dans le repertoire `/src/test/bash` qui commencent par `tests_`.
Ces scripts de tests utilisent le framework shunit2 (framework se basant sur Junit) pour lancer les tests et generer un rapport xml.    
Les tests unitaires utilisent un script `mock.sh` qui contient des fonctions qui override les fonction `systemctl is-active` `systemctl-show` et `service status`. (fonctions utilises par les deux modules).
Le script `allTI.sh` lance lui les script de tests commencants par `TI_` (tests d'integrations).   
Ces tests d'integrations ne sont pas lances automatiquement apres installations.

