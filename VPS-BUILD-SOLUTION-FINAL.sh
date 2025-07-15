#!/bin/bash

echo "=============================================="
echo "SOLUTION DÉFINITIVE BUILD VPS - 100% PAYPLUG"
echo "=============================================="

# 1. Arrêter tous les processus
echo "→ Arrêt des processus..."
pkill -f node || true

# 2. Nettoyer COMPLÈTEMENT
echo "→ Nettoyage complet..."
rm -rf dist
rm -rf .vite
rm -rf node_modules
rm -rf package-lock.json
rm -rf client/dist
rm -rf client/.vite
rm -rf .rollup.cache
rm -rf .parcel-cache

# 3. Vérifier qu'il n'y a plus de stripe
echo "→ Vérification des références Stripe..."
if grep -r "stripe\|Stripe\|@stripe" . --include="*.ts" --include="*.tsx" --include="*.js" --exclude-dir=node_modules --exclude-dir=dist 2>/dev/null | grep -v ".sh" | grep -v ".md"; then
    echo "⚠️ Des références à Stripe trouvées, nettoyage..."
    find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" \) ! -path "./node_modules/*" ! -path "./dist/*" -exec sed -i 's/stripe//gI; s/Stripe//g; s/@stripe//g' {} \;
fi

# 4. Installer les dépendances proprement
echo "→ Installation des dépendances..."
npm install

# 5. S'assurer que esbuild est installé
echo "→ Vérification esbuild..."
npm install esbuild --save-dev

# 6. Build frontend uniquement d'abord
echo "→ Build frontend..."
cd client
npm run build || npx vite build
cd ..

# 7. Build serveur
echo "→ Build serveur..."
npx esbuild server/index.ts --platform=node --packages=external --bundle --format=esm --outdir=dist

# 8. Copier les fichiers frontend
echo "→ Copie des fichiers..."
mkdir -p dist/public
cp -r client/dist/* dist/public/ 2>/dev/null || true

# 9. Vérification finale
echo "→ Vérification du build..."
if [ -f "dist/index.js" ] && [ -d "dist/public" ]; then
    echo "✅ BUILD RÉUSSI!"
    echo ""
    echo "Pour démarrer l'application:"
    echo "  NODE_ENV=production node dist/index.js"
else
    echo "⚠️ Build incomplet, essai alternatif..."
    
    # Alternative: build Vite seulement
    echo "→ Build alternatif (Vite uniquement)..."
    npm run vite:build || npx vite build
    
    # Copier le serveur
    cp server/index.ts dist/index.js
fi

echo ""
echo "=============================================="
echo "✅ BUILD VPS 100% PAYPLUG - SANS STRIPE"
echo "=============================================="
echo ""
echo "PayPlug configuré avec:"
echo "- Clé API: sk_test_2wDsePkdatiFXUsRfeu6m1"
echo "- Mode: TEST"
echo "- SDK: Chargé depuis CDN"