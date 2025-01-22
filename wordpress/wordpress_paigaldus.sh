#!/bin/bash

# Kontrollime, kas Apache on paigaldatud
APACHE2=$(dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -c 'ok installed')

# Kui Apache on paigaldatud, siis kuvame teenuse staatust
if [ $APACHE2 -eq 1 ]; then
    echo "Apache2 teenus on juba paigaldatud."
    echo "Kontrollime Apache2 teenuse staatust:"
    systemctl status apache2 --no-pager
else
    # Kui Apache ei ole paigaldatud, siis paigaldame selle
    echo "Apache2 teenus ei ole paigaldatud. Paigaldan nüüd..."
    sudo apt update
    sudo apt install -y apache2

    # Kontrollime, kas paigaldamine õnnestus
    if [ $? -eq 0 ]; then
        echo "Apache2 teenus on edukalt paigaldatud."
    else
        echo "Apache2 teenuse paigaldamisel tekkis viga."
        exit 1
    fi

    # Lubame süsteemil käivitada Apache teenuse
    echo "Käivitan Apache2 teenuse"
    sudo systemctl enable apache2
    sudo systemctl start apache2

    # Vaatame kas teenus on sees
    systemctl status apache2 --no-pager
fi

# Kontrollime, kas PHP on paigaldatud
PHP=$(dpkg-query -W -f='${Status}' php 2>/dev/null | grep -c 'ok installed')

# Kui PHP on paigaldatud, siis kuvame selle staatust
if [ $PHP -eq 1 ]; then
    echo -e "\033[32mPHP teenus on juba paigaldatud.\033[0m"
    echo "Kontrollime kas PHP eksisteerib:"
    php -v
    which php
else
    echo "PHP teenus ei ole paigaldatud. Paigaldan nüüd..."
    sudo apt update
    sudo apt install php

    # Kontrollime, kas paigaldamine õnnestus
    if [ $? -eq 0 ]; then
        echo -e "\033[32mPHP teenus on edukalt paigaldatud.\033[0m"
    else
        echo "PHP teenuse paigaldamisel tekkis viga."
        exit 1
    fi

    # Taaskäivitame Apache, et PHP töötaks korralikult
    sudo systemctl restart apache2
fi

# Kontrollime, kas MySQL on paigaldatud
MYSQL=$(dpkg-query -W -f='${Status}' mysql-server 2>/dev/null | grep -c 'ok installed')

if [ $MYSQL -eq 1 ]; then
    echo -e "\033[32mMySQL teenus on juba paigaldatud.\033[0m"
    mysql -e "SHOW DATABASES;"
else
    echo "MySQL teenus ei ole paigaldatud. Paigaldan nüüd..."
    sudo apt update
    sudo apt install mysql-server
    touch $HOME/.my.cnf
    echo "[client]" >> $HOME/.my.cnf
    echo "host = localhost" >> $HOME/.my.cnf
    echo "user = root" >> $HOME/.my.cnf
    echo "password = qwerty" >> $HOME/.my.cnf

    # Kontrollime, kas paigaldamine õnnestus
    if [ $? -eq 0 ]; then
        echo -e "\033[32mMySQL teenus on edukalt paigaldatud.\033[0m"
    else
        echo "MySQL teenuse paigaldamisel tekkis viga."
        exit 1
    fi

    # Kontrollime  MySQL olemasolu
    echo "Kontrollime MySQL olemasolu:"
    mysql -e "SHOW DATABASES;"

fi

# Kontrollime, kas phpMyAdmin on paigaldatud
PHPA=$(dpkg-query -W -f='${Status}' phpmyadmin 2>/dev/null | grep -c 'ok installed')

if [ $PHPA -eq 1 ]; then
    echo -e "\033[32mphpMyAdmin teenus on juba paigaldatud.\033[0m"
else
    echo "phpMyAdmin teenus ei ole paigaldatud. Paigaldan nüüd..."
    sudo apt update
    sudo apt install phpmyadmin

    # Kontrollime, kas paigaldamine õnnestus
    if [ $? -eq 0 ]; then
        echo -e "\033[32mphpMyAdmin teenus on edukalt paigaldatud.\033[0m"
    else
        echo "phpMyAdmin teenuse paigaldamisel tekkis viga."
        exit 1
    fi
fi

# Enne WordPressi paigaldust loome andmebaasid MySQL'ga
echo "Loon andmebaasi WordPressile:"

mysql --user="root" --password="qwerty" --execute="CREATE DATABASE wpdatabase; CREATE USER wpuser@localhost IDENTIFIED BY 'qwerty'; GRANT ALL PRIVILEGES ON wpdatabase.* TO wpuser@localhost; FLUSH PRIVILEGES; EXIT;"

# Paigaldame WordPressi
echo "Paigaldame WordPressi:"
cd /var/www/html/
sudo wget https://wordpress.org/latest.tar.gz
sudo tar xzvf latest.tar.gz
sudo cp wordpress/wp-config-sample.php wordpress/wp-config.php

echo "Muudame wp-config.php faili õiged andmebaasi seaded:"
sudo sed -i "s/database_name_here/wpdatabase/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/wpuser/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/qwerty/" /var/www/html/wordpress/wp-config.php



# Muudame faili õiguseid
echo "Muudan faili '/var/www/html/wordpress' õigused:"
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Teeme Apache 2 teenusele restardi
echo "Teeme apache2'le uuesti restardi:"
sudo systemctl restart apache2

# Kontrollime, kas WordPress töötab
echo "Kontrollime WordPressi tööd..."
IP_ADDRESS=$(hostname -I | awk '{print $1}')
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://$IP_ADDRESS)

# Kui skript saab Apache käest 200(OK) HTTP-koodi, siis teavitab skript kasutajale, et WordPress töötab
if [ "$HTTP_RESPONSE" -eq 200 ]; then
    echo "WordPress töötab."
else
    echo "WordPress ei tööta, HTTP vastus: $HTTP_RESPONSE"
    echo "Kontrollige veebiserveri ja andmebaasi seadeid."
fi

echo -e "\033[32mSisestage veebibrauserisse: http://$IP_ADDRESS ,et avada oma WordPressi leht.\033[0m"
exit 0
