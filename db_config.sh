#!/bin/bash

set -e

echo -e "\n====== INSTALLATION DB =======\n"

sudo apt install -y mysql-server
sudo systemctl enable --now mysql

echo -e "\n======== Récupération des infos de la db ==========\n"

read -p "Nom de la db : " db_name
read -p "Username : " db_username
read -sp "Password : " db_password

echo -e "\n"

if ! command -v mysql &> /dev/null; then
    echo "\nMysql not installed\n"
    sudo apt update -y && sudo apt install -y mysql-server
    sudo systemctl enable --now mysql
fi


echo -e "\n======Sécurisation de la db =======\n"
sudo mysql_secure_installation


echo -e "\n====== Création de la db et accès Root User=======\n"

sudo mysql -u root -p <<EOF
CREATE DATABASE IF NOT EXISTS ${db_name};
GRANT ALL PRIVILEGES on ${db_name}.* to ${db_username}@localhost IDENTIFIED BY '${db_password}';
FLUSH PRIVILEGES;
EXIT;
EOF

echo -e "===========Vérification de la création =======\n"
sudo mysql -u root -e "SHOW DATABASES LIKE '${db_name}';"
sudo mysql -u root -e "SELECT USER, HOST FROM mysql.user='${db_username}';"


echo -e "\n Base de données '${db_name}' et user '${db_username}' crées avec succès.\n"


sudo mysql -u root -p ${db_name} < db/SCHEME.SQL    # Ici mettre à jour le chemin vers SCHEMA.SQL qui se trouve dan le dossier phpipam
