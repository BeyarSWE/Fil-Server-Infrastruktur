#!/bin/bash
echo "--- Startar Säkerhetstest (VG-krav) ---"

# Test 1: Försöker skapa en fil i Avdelning A som användare jacob_a
echo "Test 1: Försöker skriva till Avdelning A (Ska lyckas)..."
sudo -u jacob_a touch /mnt/avdelning-a/test_fil.txt && echo "Resultat: LYCKADES (Jacob kan skriva i sin mapp)" || echo "Resultat: MISSLYCKADES"

# Test 2: Försöker skriva till Avdelning B som användare jacob_a
echo "Test 2: Försöker skriva till Avdelning B (Ska blockeras)..."
if sudo -u jacob_a touch /mnt/avdelning-b/tjuv_fil.txt 2>/dev/null; then
    echo "Resultat: MISSLYCKADES (Säkerhetsbrist! Jacob kunde skriva i fel mapp)"
else
    echo "Resultat: LYCKADES (Åtkomst nekad - Säkerheten fungerar!)"
fi

echo "--- Test slutfört ---"