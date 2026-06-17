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
DROP DATABASE IF EXISTS $db_name;
CREATE DATABASE IF NOT EXISTS $db_name;

DROP USER IF EXISTS '$db_username'@'localhost';
CREATE USER '$db_username'@'localhost' IDENTIFIED BY '$db_password';
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_username'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

echo -e "===========Vérification de la création =======\n"
sudo mysql -u root -e "SHOW DATABASES LIKE '$db_name';"


echo -e "\n Base de données $db_name et user $db_username crées avec succès.\n"