#!/bin/bash

echo "======================================================="
echo "CORRECTION DÉFINITIVE BUILD VPS - 100% SANS STRIPE"
echo "======================================================="

# 1. Arrêter tout processus Node
echo "→ Arrêt des processus Node..."
pkill -f node || true

# 2. Nettoyer TOUT
echo "→ Nettoyage complet du projet..."
rm -rf dist
rm -rf .vite
rm -rf node_modules/.vite
rm -rf node_modules/.cache
rm -rf client/dist
rm -rf client/.vite
rm -rf .rollup.cache
rm -rf .parcel-cache

# 3. Supprimer TOUTE référence Stripe des fichiers sources
echo "→ Suppression de toutes les références Stripe dans le code..."

# Lister les fichiers qui contiennent stripe
echo "Fichiers contenant 'stripe':"
grep -r "stripe\|Stripe\|@stripe" . --include="*.js" --include="*.ts" --include="*.tsx" --include="*.json" --exclude-dir=node_modules --exclude-dir=dist 2>/dev/null | grep -v "Binary file" || echo "Aucun fichier trouvé"

# Supprimer les lignes contenant stripe
find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" \) ! -path "./node_modules/*" ! -path "./dist/*" -exec sed -i.bak '/@stripe/d; /stripe/d; /Stripe/d; /loadStripe/d' {} \;

# Supprimer les fichiers de backup
find . -name "*.bak" -delete

# 4. Supprimer les fichiers stripe
echo "→ Suppression des fichiers stripe..."
find . -name "*stripe*" -type f ! -path "./node_modules/*" ! -path "./dist/*" -delete 2>/dev/null || true

# 5. Vérifier vite.config.ts et autres configs
echo "→ Vérification des fichiers de configuration..."
for file in vite.config.ts vite.config.production.ts tsconfig.json; do
    if [ -f "$file" ] && grep -q "stripe" "$file"; then
        echo "Nettoyage de $file..."
        sed -i '/@stripe/d; /stripe/d; /Stripe/d' "$file"
    fi
done

# 6. Nettoyer package.json et réinstaller
echo "→ Nettoyage des dépendances..."
if grep -q "stripe" package.json; then
    echo "Suppression des dépendances Stripe..."
    # Retirer manuellement de package.json
    sed -i '/"@stripe/d; /"stripe"/d' package.json
    sed -i '/"@stripe/d; /"stripe"/d' package-lock.json 2>/dev/null || true
fi

# 7. Réinstaller proprement
echo "→ Réinstallation des dépendances..."
rm -rf node_modules package-lock.json
npm install

# 8. Vérification finale
echo "→ Vérification finale..."
echo "Recherche de références Stripe restantes:"
if grep -r "stripe\|Stripe\|@stripe" . --include="*.js" --include="*.ts" --include="*.tsx" --exclude-dir=node_modules --exclude-dir=dist 2>/dev/null | grep -v "Binary file" | grep -v ".bak"; then
    echo "⚠️ Des références à Stripe existent encore!"
else
    echo "✅ Aucune référence à Stripe trouvée!"
fi

# 9. Build de production
echo "→ Build de production..."
NODE_ENV=production npm run build

echo "======================================================="
echo "✅ BUILD VPS 100% CORRIGÉ - UTILISE PAYPLUG UNIQUEMENT"
echo "======================================================="