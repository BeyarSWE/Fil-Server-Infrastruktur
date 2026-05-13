#!/bin/bash
echo "--- Startar Säkerhetstest (VG-krav) ---"

echo "Test 1: Försöker skapa en fil i Avdelning A som användare jacob_a (Ska lyckas)"
vagrant ssh fileserver -c "sudo su - jacob_a -c 'touch /shares/avdelning-a/lyckat_test.txt'"
if [ $? -eq 0 ]; then
    echo "✔ Test 1: Lyckades! Rättigheterna stämmer."
else
    echo "❌ Test 1: Misslyckades."
fi

echo "Test 2: Försöker skapa en fil i Avdelning B som användare jacob_a (Ska blockeras)"
vagrant ssh fileserver -c "sudo su - jacob_a -c 'touch /shares/avdelning-b/olagligt_test.txt'"
if [ $? -ne 0 ]; then
    echo "✔ Test 2: Lyckades! Jacob blev blockerad från Avdelning B."
else
    echo "❌ Test 2: Misslyckades! Säkerhetsrisk - Jacob kunde skriva i fel mapp."
fi
