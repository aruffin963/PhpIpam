#!/bin/bash

set -e

echo -e "\n =========================Installation et Configuration de phpipam ==========================\n"

echo -ne "A cette étape il faudra pas oublier les credentials utilisés au cours de la configuration de la db\n"
echo -ne "Veuillez bien renseigner les mêmes credential pour assurer une bonne installation\n"

echo -ne "Username\n"
read -p "Username : " username
echo -ne "Password\n"
read -sp "Password : " password
echo -ne "Database\n"
read -p "Database : " database

echo -ne "\n\n"

sudo apt update && sudo apt upgrade


sudo apt install wget curl net-tools git

sudo apt install -y apache2 php php-cli libapache2-mod-php

sudo systemctl enable --now apache2


cd /var/www/html/

sudo git clone --recursive https://github.com/phpipam/phpipam.git

sudo git submodule update --init --recursive
sudo cp config.dist.php config.php