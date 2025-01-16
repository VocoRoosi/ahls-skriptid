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
