#!/bin/bash

echo "============================================"
echo "FORCE CLEAN BUILD - SUPPRESSION STRIPE 100%"
echo "============================================"

# 1. Arrêter tous les processus
pkill -f node 2>/dev/null || true
pkill -f vite 2>/dev/null || true

# 2. Supprimer TOUS les fichiers de cache et build
echo "→ Suppression des caches..."
rm -rf dist
rm -rf .vite
rm -rf client/dist
rm -rf client/.vite
rm -rf .rollup.cache
rm -rf .parcel-cache
rm -rf node_modules/.cache
rm -rf node_modules/.vite
rm -rf node_modules/.rollup.cache

# 3. Nettoyer package.json et package-lock.json
echo "→ Nettoyage package.json..."
sed -i '/"stripe"/d' package.json
sed -i '/"@stripe/d' package.json
rm -f package-lock.json

# 4. Supprimer node_modules complètement
echo "→ Suppression node_modules..."
rm -rf node_modules

# 5. Nettoyer tous les fichiers sources
echo "→ Nettoyage des fichiers sources..."
find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" \) ! -path "./node_modules/*" -exec sed -i '/@stripe/d; /stripe-js/d; /loadStripe/d' {} \; 2>/dev/null

# 6. Supprimer les fichiers compilés
echo "→ Suppression des fichiers compilés..."
find . -name "*.js.map" -delete
find . -name "*.d.ts" -delete
find . -name "*.tsbuildinfo" -delete

# 7. Réinstaller PROPREMENT
echo "→ Réinstallation propre..."
npm install

# 8. Vérifier qu'il n'y a plus de références
echo "→ Vérification finale..."
if grep -r "stripe\|@stripe" . --include="*.js" --include="*.ts" --include="*.tsx" --include="*.json" --exclude-dir=node_modules 2>/dev/null; then
    echo "⚠️ Références trouvées, suppression forcée..."
    find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" \) ! -path "./node_modules/*" -exec sed -i 's/stripe//gI; s/@stripe//gI; s/loadStripe//gI' {} \;
else
    echo "✅ Aucune référence trouvée"
fi

# 9. Build de production
echo "→ Build de production..."
npm run build

echo "============================================"
echo "✅ BUILD FORCE CLEAN TERMINÉ"
echo "============================================"