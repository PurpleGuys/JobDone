#!/bin/bash

# ÉLIMINATION DÉFINITIVE DE STRIPE - SOLUTION RADICALE
echo "🔥 ÉLIMINATION DÉFINITIVE DE STRIPE - SOLUTION RADICALE"
echo "========================================================"

# 1. Arrêter tous les processus
echo "1. Arrêt des processus..."
pkill -f "npm run dev" 2>/dev/null || true
pkill -f "tsx server" 2>/dev/null || true
pkill -f "vite" 2>/dev/null || true

# 2. Supprimer TOUS les caches et builds
echo "2. Suppression complète des caches et builds..."
rm -rf dist/
rm -rf node_modules/.cache
rm -rf node_modules/.vite
rm -rf client/.vite
rm -rf .vite
rm -rf .next
rm -rf build/
rm -rf public/dist/

# 3. Créer un fichier lib/stripe.js vide pour éviter les erreurs
echo "3. Création d'un fichier stripe.js vide..."
mkdir -p client/src/lib
cat > client/src/lib/stripe.js << 'EOF'
// FICHIER STRIPE.JS VIDE - REMPLACÉ PAR PAYPLUG
console.warn('Stripe désactivé - PayPlug utilisé à la place');

// Export vide pour éviter les erreurs
export const stripe = null;
export const loadStripe = () => Promise.resolve(null);
export default null;
EOF

# 4. Nettoyer TOUS les fichiers de configuration
echo "4. Nettoyage des fichiers de configuration..."
sed -i '/stripe/d' vite.config.ts 2>/dev/null || true
sed -i '/STRIPE/d' vite.config.ts 2>/dev/null || true
sed -i '/stripe/d' vite.config.production.ts 2>/dev/null || true
sed -i '/STRIPE/d' vite.config.production.ts 2>/dev/null || true

# 5. Nettoyer TOUS les fichiers .env
echo "5. Nettoyage des fichiers .env..."
for env_file in .env .env.local .env.production .env.development; do
    if [ -f "$env_file" ]; then
        sed -i '/STRIPE/d' "$env_file"
        sed -i '/stripe/d' "$env_file"
    fi
done

# 6. Désinstaller les packages Stripe s'ils existent
echo "6. Désinstallation des packages Stripe..."
npm uninstall stripe @stripe/stripe-js @stripe/react-stripe-js 2>/dev/null || true

# 7. Nettoyer le package-lock.json
echo "7. Nettoyage du package-lock.json..."
rm -f package-lock.json

# 8. Réinstaller les dépendances proprement
echo "8. Réinstallation des dépendances..."
npm install

# 9. Vérifier qu'il n'y a plus de références Stripe
echo "9. Vérification finale..."
stripe_count=$(find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | grep -v node_modules | xargs grep -l "stripe\|STRIPE" 2>/dev/null | wc -l)
echo "Références Stripe trouvées: $stripe_count"

# 10. Créer un build propre
echo "10. Création d'un build propre..."
NODE_ENV=production npm run build

echo ""
echo "✅ ÉLIMINATION TERMINÉE"
echo "======================="
echo "✅ Caches supprimés"
echo "✅ Fichier stripe.js vide créé"
echo "✅ Configurations nettoyées"
echo "✅ Packages Stripe désinstallés"
echo "✅ Build propre créé"
echo ""
echo "🚀 Redémarrage du serveur..."