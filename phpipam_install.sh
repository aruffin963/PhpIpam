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

sudo apt install php-mysql libapache2-mod-php php-gd php-ldap php-curl php-gmp php-xml php-mbstring git -y

sudo systemctl enable --now apache2

cd "/var/www/html/phpipam/"

sudo git clone --recursive https://github.com/phpipam/phpipam.git

sudo git submodule update --init --recursive

cd "/var/www/html/phpipam/"

sudo cp /var/www/html/phpipam/config.dist.php config.php

CONFIG_FILE="/var/www/html/phpipam/config.php"

sudo sed -i "s|\$db\['host'\] = .*;|\$db['host'] = '127.0.0.1';|" $CONFIG_FILE
sudo sed -i "s|\$db\['user'\] = .*;|\$db['user'] = '$username';|" $CONFIG_FILE
sudo sed -i "s|\$db\['pass'\] = .*;|\$db['pass'] = '$password';|" $CONFIG_FILE
sudo sed -i "s|\$db\['name'\] = .*;|\$db['name'] = '$database';|" $CONFIG_FILE
sudo sed -i "s|\$db\['name'\] = .*;|\$db['name'] = '$database';|" $CONFIG_FILE
sudo sed -i "s|define('BASE', \"/\");|define('BASE', \"/\");|" $CONFIG_FILE


sudo chown -R www-data:www-data /var/www/html/phpipam
sudo chown -R 755 /var/www/html/phpipam

sudo mysql -u root -p $db_name < /var/www/html/phpipam/db/SCHEME.SQL    # Ici mettre à jour le chemin vers SCHEMA.SQL qui se trouve dan le dossier phpipam

sudo systemctl restart apache2

VHOST_FILE="/etc/apache2/sites-available/000-default.conf"
WEB_PATH="/var/www/html/phpipam"

if grep -q "$WEB_PATH" "$VHOST_FILE"; then
    ech -ne "\n dossier déjà existant"
else
    sudo bash -c "cat > $VHOST_FILE" <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/phpipam

    <Directory /var/www/html/phpipam>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
sudo systemctl reload apache2.service
fi

sudo a2enmod rewrite
sudo systemctl restart apache2.service

sudo curl http://localhost/phpipam