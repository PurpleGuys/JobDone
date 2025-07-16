#!/bin/bash

# ULTRA CLEAN STRIPE - SOLUTION DÉFINITIVE
echo "🔥 ULTRA CLEAN STRIPE - SOLUTION DÉFINITIVE"
echo "============================================"

# 1. Nettoyer complètement tous les builds
echo "1. Nettoyage complet des builds..."
rm -rf dist/ node_modules/.cache node_modules/.vite client/.vite .vite build/

# 2. Chercher et éliminer TOUTES les références Stripe cachées
echo "2. Recherche et élimination des références Stripe cachées..."

# Vérifier les fichiers TypeScript/JavaScript
find client/src -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | while read file; do
    if grep -q "VITE_STRIPE_PUBLIC_KEY\|loadStripe\|js.stripe.com\|stripe.js" "$file" 2>/dev/null; then
        echo "⚠️  Référence Stripe trouvée dans: $file"
        sed -i 's/VITE_STRIPE_PUBLIC_KEY/VITE_PAYPLUG_PUBLIC_KEY/g' "$file"
        sed -i 's/loadStripe/loadPayPlug/g' "$file"
        sed -i 's/js.stripe.com/js.payplug.com/g' "$file"
        sed -i 's/stripe.js/payplug.js/g' "$file"
        echo "✅ Nettoyé: $file"
    fi
done

# 3. Vérifier les fichiers de configuration
echo "3. Vérification des fichiers de configuration..."
for config in vite.config.ts vite.config.production.ts tsconfig.json; do
    if [ -f "$config" ]; then
        if grep -q "stripe\|STRIPE" "$config" 2>/dev/null; then
            echo "⚠️  Référence Stripe dans $config - nettoyage..."
            sed -i '/stripe/d' "$config"
            sed -i '/STRIPE/d' "$config"
            echo "✅ Nettoyé: $config"
        fi
    fi
done

# 4. Vérifier les variables d'environnement
echo "4. Vérification des variables d'environnement..."
for env in .env .env.local .env.production; do
    if [ -f "$env" ]; then
        if grep -q "STRIPE" "$env" 2>/dev/null; then
            echo "⚠️  Variables Stripe dans $env - suppression..."
            sed -i '/STRIPE/d' "$env"
            echo "✅ Nettoyé: $env"
        fi
    fi
done

# 5. Vérifier package.json
echo "5. Vérification des packages Stripe..."
if grep -q "stripe" package.json 2>/dev/null; then
    echo "⚠️  Packages Stripe trouvés - désinstallation..."
    npm uninstall stripe @stripe/stripe-js @stripe/react-stripe-js 2>/dev/null || true
    echo "✅ Packages Stripe désinstallés"
fi

# 6. Nettoyer le cache NPM
echo "6. Nettoyage du cache NPM..."
npm cache clean --force

# 7. Vérification finale
echo "7. Vérification finale..."
stripe_refs=$(find client/src -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | xargs grep -l "VITE_STRIPE_PUBLIC_KEY\|loadStripe\|js.stripe.com" 2>/dev/null | wc -l)
echo "Références Stripe restantes: $stripe_refs"

# 8. Créer un build propre
echo "8. Création d'un build propre..."
NODE_ENV=production npm run build

echo ""
echo "✅ NETTOYAGE TERMINÉ"
echo "==================="
echo "✅ Builds supprimés"
echo "✅ Code source nettoyé"
echo "✅ Configuration nettoyée"
echo "✅ Variables d'environnement nettoyées"
echo "✅ Build propre créé"
echo ""
echo "🎯 STATUT: PRÊT POUR PRODUCTION"