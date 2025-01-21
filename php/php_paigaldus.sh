#!/bin/bash

# Kontrollime, kas PHP on paigaldatud
PHP=$(dpkg-query -W -f='${Status}' php 2>/dev/null | grep -c 'ok installed')

# Kui PHP on paigaldatud, siis kuvame selle staatust
if [ $PHP -eq 1 ]; then
    echo "PHP teenus on juba paigaldatud."
    echo "Kontrollime kas PHP eksisteerib:"
    # Kontrollime PHP versiooni
    php -v
    which php
else
    # Kui PHP ei ole paigaldatud, siis paigaldame selle
    echo "PHP teenus ei ole paigaldatud. Paigaldan nüüd..."
    sudo apt update
    sudo apt install php

    # Kontrollime, kas paigaldamine õnnestus
    if [ $? -eq 0 ]; then
        echo "PHP teenus on edukalt paigaldatud."
    else
        echo "PHP teenuse paigaldamisel tekkis viga."
        exit 1
    fi

    # Lülitame Apache2 sisse ja käivitame selle
    
    echo "Lülitame Apache 2 sisse ja käivitame selle:"
    sudo systemctl enable apache2
    sudo systemctl start apache2

    # Teeme restardi Apache2'le ,et kõik töötaks nagu vaja
    echo "Teeme restarti Apache2'le igaks juhuks:"
    sudo systemctl restart apache2

    # Kontrollime, kas PHP töötab koos Apachega ja kas on PHP ikka olemas
    echo "Kontrollime kas Apache2 on sees ja kas php on installitud:"
    systemctl status apache2 --no-pager
    php -v
    which php
fi
