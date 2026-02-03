#!/bin/bash
# Description: Provisionnement d'utilisateur avec groupe users natif et statut SSH
# Author: hddah

set -e

# Verification privileges root
if [[ $EUID -ne 0 ]]; then
   echo "Erreur : privileges root requis"
   exit 1
fi

LOG_FILE="/var/log/user_management.log"

# --- Identification utilisateur ---
while true; do
    # Ajout de -r ici
    read -r -p "Nom d'utilisateur : " USERNAME
    [[ -z "$USERNAME" ]] && continue
    
    if id "$USERNAME" &>/dev/null; then
        read -r -p "Utilisateur '$USERNAME' existant. Reessayer ? (y/n) : " AGAIN
        [[ "$AGAIN" =~ ^[Nn]$ ]] && exit 0
    else
        break
    fi
done

# --- Gestion des groupes ---
PRIMARY_GROUP="users"
ADDITIONAL_GROUP=""

echo "--- Groupes systeme disponibles ---"
cut -d: -f1 /etc/group | column
echo "------------------------------------"

while true; do
    read -r -p "Groupe secondaire (Laissez vide pour aucun) : " SEC_GROUP
    
    if [[ -z "$SEC_GROUP" ]]; then
        echo "Aucun groupe secondaire selectionne."
        break
    fi

    if getent group "$SEC_GROUP" > /dev/null; then
        ADDITIONAL_GROUP="$SEC_GROUP"
        break
    else
        echo "Groupe '$SEC_GROUP' introuvable."
        echo "1) Creer le groupe | 2) Reessayer | 3) Annuler groupe secondaire"
        read -r -p "Action : " OPT
        case $OPT in
            1) groupadd "$SEC_GROUP"; ADDITIONAL_GROUP="$SEC_GROUP"; break ;;
            2) continue ;;
            3) ADDITIONAL_GROUP=""; break ;;
            *) echo "Option invalide" ;;
        esac
    fi
done

# --- Execution de la creation ---
PASSWORD=$(openssl rand -base64 18)

if [[ -n "$ADDITIONAL_GROUP" ]]; then
    useradd -m -g "$PRIMARY_GROUP" -G "$ADDITIONAL_GROUP" -s /bin/bash "$USERNAME"
    GROUP_LOG="$PRIMARY_GROUP,$ADDITIONAL_GROUP"
else
    useradd -m -g "$PRIMARY_GROUP" -s /bin/bash "$USERNAME"
    GROUP_LOG="$PRIMARY_GROUP"
fi

# Protection des variables avec des guillemets
echo "$USERNAME:$PASSWORD" | chpasswd
chage -d 0 "$USERNAME" 

# --- Configuration SSH ---
SSH_STATUS="NON"
read -r -p "Activer SSH pour $USERNAME ? (y/n) : " SSH_OPT
if [[ "$SSH_OPT" =~ ^[Yy]$ ]]; then
    SSH_DIR="/home/$USERNAME/.ssh"
    mkdir -p "$SSH_DIR"
    touch "$SSH_DIR/authorized_keys"
    chmod 700 "$SSH_DIR"
    chmod 600 "$SSH_DIR/authorized_keys"
    chown -R "$USERNAME":"$PRIMARY_GROUP" "$SSH_DIR"
    SSH_STATUS="OUI"
fi

# --- Rapport et Audit ---
echo "------------------------------------"
echo "Statut : SUCCES"
echo "Utilisateur : $USERNAME"
echo "Groupe primaire : $PRIMARY_GROUP"
[[ -n "$ADDITIONAL_GROUP" ]] && echo "Groupe secondaire : $ADDITIONAL_GROUP"
echo "Acces SSH : $SSH_STATUS"
echo "Mot de passe temporaire : $PASSWORD"
echo "------------------------------------"

# Utilisation de printf ou protection stricte des variables pour le log
echo "$(date '+%Y-%m-%d %H:%M:%S') - CREATE - User: $USERNAME, Groups: $GROUP_LOG, SSH: $SSH_STATUS, Admin: $USER" >> "$LOG_FILE"