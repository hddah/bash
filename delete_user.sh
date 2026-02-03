#!/bin/bash
# Description : Suppression d'utilisateur avec enumeration complète
# Author: hddah

set -e

# Verification privileges root
if [[ $EUID -ne 0 ]]; then
   echo "Erreur : privileges root requis"
   exit 1
fi

LOG_FILE="/var/log/user_management.log"

# --- Enumeration des utilisateurs ---
echo "--- Liste de tous les utilisateurs systeme ---"
cut -d: -f1 /etc/passwd | sort | column
echo "-----------------------------------------------"

# --- Identification cible ---
while true; do
    read -r -p "Utilisateur a supprimer : " USERNAME
    [[ -z "$USERNAME" ]] && continue

    if id "$USERNAME" &>/dev/null; then
        break
    else
        read -r -p "Utilisateur '$USERNAME' introuvable. Reessayer ? (y/n) : " AGAIN
        [[ "$AGAIN" =~ ^[Nn]$ ]] && exit 0
    fi
done

# --- Nettoyage des processus ---
if pgrep -u "$USERNAME" > /dev/null; then
    echo "Processus actifs detectes pour l'utilisateur $USERNAME."
    read -r -p "Terminer les processus et continuer ? (y/n) : " KILL_IT
    if [[ "$KILL_IT" =~ ^[Yy]$ ]]; then
        # pkill est souvent plus précis pour les UID
        pkill -u "$USERNAME" || true
        sleep 1
    else
        echo "Operation annulee." && exit 1
    fi
fi

# --- Traitement des donnees ---
echo "1) Supprimer le compte uniquement | 2) Supprimer le compte et le repertoire home"
read -r -p "Selection : " MODE

case $MODE in
    1) userdel "$USERNAME"; DATA="Home conserve" ;;
    2) userdel -r "$USERNAME"; DATA="Home supprime" ;;
    *) echo "Option invalide"; exit 1 ;;
esac

# --- Audit ---
echo "Utilisateur $USERNAME supprime ($DATA)."
echo "$(date '+%Y-%m-%d %H:%M:%S') - DELETE - User: $USERNAME, Status: $DATA, Admin: $USER" >> "$LOG_FILE"