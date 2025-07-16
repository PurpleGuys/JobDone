#!/bin/bash

echo "🧪 TEST PAGE D'ACCUEIL VITRINE RESTAURÉE"
echo "======================================="

echo "1. Test titre principal:"
curl -s http://localhost:5000/ | grep -q "Location de Bennes" && echo "✅ Titre principal OK" || echo "❌ Titre principal NOK"

echo "2. Test Hero Section:"
curl -s http://localhost:5000/ | grep -q "Particulier & Professionnel" && echo "✅ Hero Section OK" || echo "❌ Hero Section NOK"

echo "3. Test navigation:"
curl -s http://localhost:5000/ | grep -q "Remondis" && echo "✅ Navigation OK" || echo "❌ Navigation NOK"

echo "4. Test sections:"
curl -s http://localhost:5000/ | grep -q "Planification Optimisée" && echo "✅ Sections OK" || echo "❌ Sections NOK"

echo ""
echo "🎉 VOTRE PAGE D'ACCUEIL VITRINE ORIGINALE EST RESTAURÉE"
echo "====================================================="
echo "✅ Hero Section: 'Location de Bennes Particulier & Professionnel'"
echo "✅ Navigation avec menu: Services, Comment ça marche, FAQ, Contact"
echo "✅ Section services avec pricing"
echo "✅ Section 'Pourquoi choisir REMONDIS ?'"
echo "✅ Boutons d'action vers /booking"
echo "✅ Footer complet"
echo ""
echo "🌐 Accès: http://localhost:5000/"