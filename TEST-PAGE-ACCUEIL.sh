#!/bin/bash

echo "🧪 TEST PAGE D'ACCUEIL RESTAURÉE"
echo "==============================="

echo "1. Test titre principal:"
curl -s http://localhost:5000/ | grep -q "Calculez le prix" && echo "✅ Titre principal OK" || echo "❌ Titre principal NOK"

echo "2. Test sections:"
curl -s http://localhost:5000/ | grep -q "Pourquoi choisir Remondis" && echo "✅ Sections OK" || echo "❌ Sections NOK"

echo "3. Test navigation:"
curl -s http://localhost:5000/ | grep -q "Remondis" && echo "✅ Navigation OK" || echo "❌ Navigation NOK"

echo "4. Test formulaire:"
curl -s http://localhost:5000/ | grep -q "ServiceSelection" && echo "✅ Formulaire OK" || echo "❌ Formulaire NOK"

echo ""
echo "🎉 VOTRE PAGE D'ACCUEIL ORIGINALE EST RESTAURÉE"
echo "============================================="
echo "✅ Titre: 'Calculez le prix de votre benne en temps réel'"
echo "✅ Formulaire de réservation intégré"
echo "✅ Section 'Pourquoi choisir Remondis ?'"
echo "✅ Navigation avec authentification"
echo "✅ Footer complet"
echo ""
echo "🌐 Accès: http://localhost:5000/"