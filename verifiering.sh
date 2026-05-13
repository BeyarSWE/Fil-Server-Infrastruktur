#!/bin/bash

# ================================================
#    🛡️  SÄKERHETSTEST: FILSERVER-PROJEKT  🛡️
# ================================================
echo ""
echo "--- Startar kontroll av rättigheter ---"
echo ""

# --- TEST 1: AVDELNING A ---
echo "📂 TEST 1: Försöker skriva till Avdelning A..."
echo "👤 Agerar som: jacob_a"

if sudo -u jacob_a touch /mnt/avdelning-a/test_fil.txt 2>/dev/null; then
    echo "✅ RESULTAT: LYCKADES! Jacob kan skriva i sin egen mapp."
    echo "   (Helt korrekt - Jacob tillhör Grupp A)"
else
    echo "❌ RESULTAT: MISSLYCKADES! Jacob blev stoppad vid dörren."
    echo "   (Kontrollera om NFS är monterat eller om Jacob skapats på klienten)"
fi

echo ""
echo "------------------------------------------------"
echo ""

# --- TEST 2: AVDELNING B ---
echo "🔒 TEST 2: Försöker skriva till Avdelning B..."
echo "👤 Agerar som: jacob_a"

if sudo -u jacob_a touch /mnt/avdelning-b/tjuv_fil.txt 2>/dev/null; then
    echo "🚨 RESULTAT: MISSLYCKADES! Allvarlig säkerhetsbrist."
    echo "   (Jacob kunde skriva i fel mapp! Kontrollera rättigheterna 0770)"
else
    echo "✅ RESULTAT: LYCKADES! Åtkomst nekad - Säkerheten fungerar."
    echo "   (Jacob är helt blockerad från Avdelning B precis som planerat)"
fi

echo ""
echo "================================================"
echo "      🏁 TEST SLUTFÖRT - BRA JOBBAT! 🏁       "
echo "================================================"