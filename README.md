# bash
# Outils d'automatisation pour l'administration système Linux.

/create_user.sh

Script de création sécurisée d'utilisateurs.

# Fonctions :
  - Vérification de l'existence de l'utilisateur (boucle de correction).
  - Gestion des groupes (existant, création ou défaut).
  - Génération d'un mot de passe fort (30 caractères).
  - Forçage du changement de mot de passe au premier login.
  - Initialisation du répertoire .ssh avec permissions restrictives.
  - Journalisation dans /var/log/user_management.log.

# Utilisation : 
    #1. Installé le depot du script : 
         wget https://raw.githubusercontent.com/hddah/bash/main/create_user.sh
    #2. Donner les permissions d'exécution aux scripts :
         chmod +x ./create_user.sh
    #3. Lancer les scripts avec les privilèges root :
         sudo ./create_user.sh
    #4. Pour visualiser les dernières actions d'audit : 
          cat/var/log/user_management.log

/delete_user.sh

Script de suppression d'utilisateurs.

# Fonctions :
  - Vérification de l'existence de l'utilisateur.
  - Fermeture forcée des processus actifs de la cible.
  - Choix de suppression ou conservation du répertoire personnel.
  - Journalisation dans /var/log/user_management.log.

# Utilisation : 
    #1. Installé le depot du script : 
         wget https://raw.githubusercontent.com/hddah/bash/main/delete_user.sh
    #2. Donner les permissions d'exécution aux scripts :
         chmod +x ./delete_user.sh
    #3. Lancer les scripts avec les privilèges root :
         sudo ./delete_user.
    #4. Pour visualiser les dernières actions d'audit : 
          cat/var/log/user_management.log


# Instalation du repository : 
  git clone https://github.com/hddah/bash.git

  cd bash



  
