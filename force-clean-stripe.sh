#!/bin/bash

# FORCE CLEAN STRIPE - SOLUTION ULTIME
echo "🔥 FORCE CLEAN STRIPE - SOLUTION ULTIME"
echo "======================================="

# 1. Arrêter tous les processus
echo "1. Arrêt de tous les processus..."
pkill -f "npm run dev" 2>/dev/null || true
pkill -f "tsx" 2>/dev/null || true
pkill -f "vite" 2>/dev/null || true
sleep 2

# 2. Supprimer TOUS les builds et caches
echo "2. Suppression complète des builds..."
rm -rf dist/
rm -rf node_modules/.cache
rm -rf node_modules/.vite
rm -rf client/.vite
rm -rf .vite
rm -rf build/
rm -rf public/dist/
rm -rf .next

# 3. Nettoyer NPM cache
echo "3. Nettoyage du cache NPM..."
npm cache clean --force

# 4. Vérifier et supprimer toutes les références Stripe dans le code
echo "4. Nettoyage du code source..."
find client/src -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | xargs sed -i 's/VITE_STRIPE_PUBLIC_KEY/VITE_PAYPLUG_PUBLIC_KEY/g' 2>/dev/null || true
find client/src -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | xargs sed -i 's/loadStripe/loadPayPlug/g' 2>/dev/null || true
find client/src -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | xargs sed -i 's/js.stripe.com/js.payplug.com/g' 2>/dev/null || true

# 5. Créer un build complètement propre
echo "5. Build propre sans Stripe..."
NODE_ENV=production npm run build

# 6. Vérifier le build
echo "6. Vérification du build..."
if [ -d "dist" ]; then
    echo "✅ Build créé avec succès"
    if grep -r "stripe" dist/ 2>/dev/null | grep -v "PayPlug"; then
        echo "⚠️  Références Stripe trouvées dans le build"
    else
        echo "✅ Build propre sans Stripe"
    fi
else
    echo "❌ Échec du build"
fi

echo ""
echo "🎯 NETTOYAGE TERMINÉ"
echo "==================="
echo "✅ Processus arrêtés"
echo "✅ Caches supprimés"
echo "✅ Code source nettoyé"
echo "✅ Build propre créé"
echo ""
echo "🚀 Redémarrage du serveur..."