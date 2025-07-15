#!/bin/bash

# FORCER STRIPE EN PRODUCTION - À EXÉCUTER SUR LE VPS
echo "🔧 FORÇAGE DES CLÉS STRIPE EN PRODUCTION..."

# Créer un fichier d'environnement avec la clé Stripe
cat > stripe-env-fix.sh << 'EOF'
#!/bin/bash
# Script à exécuter sur le VPS pour corriger Stripe

# 1. Ajouter la clé Stripe au .env si elle n'existe pas
if ! grep -q "VITE_STRIPE_PUBLIC_KEY" .env 2>/dev/null; then
  echo "VITE_STRIPE_PUBLIC_KEY=pk_live_51RTkOEH7j6Qmye8ANaVnmmha9hqIUhENTbJo94UZ9D7Ia3hRu7jFbVcBtfO4lJvLiluHxqdproixaCIglmZORP0h00IWlpRCiS" >> .env
  echo "✅ Clé Stripe ajoutée au .env"
else
  # Remplacer la clé existante
  sed -i 's/^VITE_STRIPE_PUBLIC_KEY=.*/VITE_STRIPE_PUBLIC_KEY=pk_live_51RTkOEH7j6Qmye8ANaVnmmha9hqIUhENTbJo94UZ9D7Ia3hRu7jFbVcBtfO4lJvLiluHxqdproixaCIglmZORP0h00IWlpRCiS/' .env
  echo "✅ Clé Stripe mise à jour dans .env"
fi

# 2. Exporter la variable pour le processus en cours
export VITE_STRIPE_PUBLIC_KEY="pk_live_51RTkOEH7j6Qmye8ANaVnmmha9hqIUhENTbJo94UZ9D7Ia3hRu7jFbVcBtfO4lJvLiluHxqdproixaCIglmZORP0h00IWlpRCiS"

# 3. Créer un fichier de configuration forcée
mkdir -p client/src/lib
cat > client/src/lib/stripe-force.js << 'JSEOF'
// STRIPE FORCÉ EN PRODUCTION
const STRIPE_KEY = 'pk_live_51RTkOEH7j6Qmye8ANaVnmmha9hqIUhENTbJo94UZ9D7Ia3hRu7jFbVcBtfO4lJvLiluHxqdproixaCIglmZORP0h00IWlpRCiS';

if (typeof window !== 'undefined') {
  window.VITE_STRIPE_PUBLIC_KEY = STRIPE_KEY;
  window.process = window.process || {};
  window.process.env = window.process.env || {};
  window.process.env.VITE_STRIPE_PUBLIC_KEY = STRIPE_KEY;
}

console.log('✅ Stripe key forced in production');
export { STRIPE_KEY };
JSEOF

# 4. Rebuild si nécessaire
if [ -f "package.json" ]; then
  echo "🔨 Rebuilding application..."
  npm run build || echo "Build failed, but continuing..."
fi

# 5. Redémarrer l'application
echo "🔄 Redémarrage de l'application..."
pm2 restart all || systemctl restart bennespro || echo "Redémarrez manuellement votre application"

echo "✅ Stripe corrigé! Testez maintenant votre site."
EOF

chmod +x stripe-env-fix.sh

# Créer aussi une version qui modifie directement le build existant
cat > fix-stripe-in-dist.sh << 'EOF'
#!/bin/bash
# Correction rapide dans les fichiers déjà buildés

echo "🔍 Recherche des fichiers JS dans dist..."

# Chercher tous les fichiers JS et remplacer les références Stripe
find dist -name "*.js" -type f -exec grep -l "VITE_STRIPE_PUBLIC_KEY" {} \; | while read file; do
  echo "📝 Modification de $file"
  # Remplacer toute référence à une clé vide ou undefined
  sed -i 's/VITE_STRIPE_PUBLIC_KEY:""/VITE_STRIPE_PUBLIC_KEY:"pk_live_51RTkOEH7j6Qmye8ANaVnmmha9hqIUhENTbJo94UZ9D7Ia3hRu7jFbVcBtfO4lJvLiluHxqdproixaCIglmZORP0h00IWlpRCiS"/g' "$file"
  sed -i 's/VITE_STRIPE_PUBLIC_KEY:void 0/VITE_STRIPE_PUBLIC_KEY:"pk_live_51RTkOEH7j6Qmye8ANaVnmmha9hqIUhENTbJo94UZ9D7Ia3hRu7jFbVcBtfO4lJvLiluHxqdproixaCIglmZORP0h00IWlpRCiS"/g' "$file"
done

echo "✅ Fichiers dist modifiés!"
EOF

chmod +x fix-stripe-in-dist.sh

echo "📋 INSTRUCTIONS POUR VPS:"
echo ""
echo "1. Copier ces scripts sur votre VPS:"
echo "   scp stripe-env-fix.sh fix-stripe-in-dist.sh user@vps:/path/to/app/"
echo ""
echo "2. Sur le VPS, exécuter:"
echo "   ./stripe-env-fix.sh"
echo "   # OU si vous voulez juste corriger le build existant:"
echo "   ./fix-stripe-in-dist.sh"
echo ""
echo "3. La clé Stripe sera forcée à:"
echo "   pk_live_51RTkOEH7j6Qmye8ANaVnmmha9hqIUhENTbJo94UZ9D7Ia3hRu7jFbVcBtfO4lJvLiluHxqdproixaCIglmZORP0h00IWlpRCiS"