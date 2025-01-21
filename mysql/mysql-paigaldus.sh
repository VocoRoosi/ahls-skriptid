MYSQL=$(dpkg-query -W -f='${Status}' mysql-server 2>/dev/null | grep -c 'ok installed')


if [ $MYSQL -eq 1 ]; then
    echo "MySQL teenus on juba paigaldatud."
    echo "Kontrollime MySQL olemasolu:"
    mysql

else
    # Kui MySQL ei ole paigaldatud, siis paigaldame selle
    echo "MySQL teenus ei ole paigaldatud. Paigaldan nüüd..."
    sudo apt update
    sudo apt install  mysql-server
    touch $HOME/.my.cnf
    echo "[client]" >> $HOME/.my.cnf
    echo "host = localhost" >> $HOME/.my.cnf
    echo "user = root" >> $HOME/.my.cnf
    echo "password = qwerty" >> $HOME/.my.cnf

    # Kontrollime, kas paigaldamine õnnestus
    if [ $? -eq 0 ]; then
        echo "MySQL teenus on edukalt paigaldatud."
    else
        echo "MySQL  teenuse paigaldamisel tekkis viga."
        exit 1
    fi

    # Kontrollime  MySQL olemasolu
    echo "Kontrollime MySQL olemasolu:"
    mysql



fi
