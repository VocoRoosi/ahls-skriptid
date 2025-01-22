#!/bin/bash

# Kontrollime, kas phpMyAdmin on paigaldatud
PHPA=$(dpkg-query -W -f='${Status}' phpmyadmin 2>/dev/null | grep -c 'ok installed')

# Kui phpMyAdmin on paigaldatud, siis kuvame teenuse staatust
if [ $PHPA -eq 1 ]; then
    echo "phpMyAdmin teenus on juba paigaldatud."
    echo "Vaatame kas kataloog eksisteerib:"

    if [ -d "/usr/share/phpmyadmin" ]; then
        echo "phpMyAdmin kataloog on olemas: /usr/share/phpmyadmin"
    else
        echo "phpMyAdmin kataloogi ei leitud. Paigaldamine ei õnnestunud või midagi on valesti."
        exit 1
    fi

else
    # Kui Apache ei ole paigaldatud, siis paigaldame selle
    echo "phpMyAdmini teenus ei ole paigaldatud. Paigaldan nüüd..."
    sudo apt update
    sudo apt install phpmyadmin

    # Kontrollime, kas paigaldamine õnnestus
    if [ $? -eq 0 ]; then
        echo "phpMyAdmin teenus on edukalt paigaldatud."
    else
        echo "phpMyAdmin teenuse paigaldamisel tekkis viga."
        exit 1
    fi

    # Kontrollime, kas phpMyAdmini kataloog eksisteerib
    echo "Vaatame kas kataloog on eksisteerib:"

    if [ -d "/usr/share/phpmyadmin" ]; then
   	 echo "phpMyAdmin on õigesti paigaldatud ja asub /usr/share/phpmyadmin"
    else
    	 echo "phpMyAdmin kataloogi ei leitud, paigaldamine ei õnnestunud."
    exit 1


    fi
fi
