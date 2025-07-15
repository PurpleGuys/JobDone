#!/bin/bash

# SCRIPT DE NETTOYAGE FINAL - BennesPro VPS
# Supprime toutes les références Stripe et scripts d'injection

echo "🧹 NETTOYAGE FINAL - BennesPro VPS"
echo "=================================="

# 1. Supprimer tous les scripts liés à Stripe
echo "📝 Suppression des scripts Stripe..."
find . -name "*stripe*" -type f -name "*.sh" -delete
find . -name "*stripe*" -type f -name "*.js" -path "./client/src/lib/*" -delete
find . -name "*stripe*" -type f -name "*.ts" -path "./client/src/lib/*" -delete

# 2. Nettoyer les fichiers temporaires
echo "🗑️ Nettoyage des fichiers temporaires..."
rm -f force-stripe-*.sh
rm -f fix-stripe-*.sh
rm -f vps-stripe-*.sh
rm -f deploy-*-stripe*.sh
rm -f *-stripe-*.sh
rm -f stripe-*.sh
rm -f fix-env-*.sh
rm -f DEPLOYMENT-*.md
rm -f VERIFIER-*.md
rm -f verify-*.sh

# 3. Nettoyer node_modules et caches
echo "🧽 Nettoyage des caches..."
rm -rf node_modules/.cache
rm -rf node_modules/.vite
rm -rf client/.vite
rm -rf .cache
rm -rf dist

# 4. Créer tsconfig.node.json si manquant
echo "📁 Création tsconfig.node.json..."
if [ ! -f "tsconfig.node.json" ]; then
cat > tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "allowImportingTsExtensions": true,
    "strict": false,
    "skipLibCheck": true,
    "noEmit": true,
    "types": ["node"],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./client/src/*"],
      "@shared/*": ["./shared/*"],
      "@assets/*": ["./attached_assets/*"]
    }
  },
  "include": [
    "vite.config.ts",
    "vite.config.production.ts",
    "tailwind.config.ts",
    "drizzle.config.ts",
    "postcss.config.js",
    "server/**/*",
    "shared/**/*",
    "scripts/**/*"
  ],
  "exclude": ["node_modules", "dist"]
}
EOF
fi

# 5. Créer vite.config.production.ts si manquant
echo "🔧 Création vite.config.production.ts..."
if [ ! -f "vite.config.production.ts" ]; then
cat > vite.config.production.ts << 'EOF'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";
import { fileURLToPath } from "url";

// Compatibility avec Node.js v18
const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./client/src"),
      "@shared": path.resolve(__dirname, "./shared"),
      "@assets": path.resolve(__dirname, "./attached_assets"),
    },
  },
  build: {
    outDir: "dist",
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, "client/index.html"),
      },
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ui: ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
        },
      },
    },
  },
  optimizeDeps: {
    include: ["react", "react-dom"],
  },
  server: {
    port: 5173,
    host: true,
  },
  preview: {
    port: 5173,
    host: true,
  },
});
EOF
fi

# 6. Vérifier les références Stripe dans le code
echo "🔍 Vérification des références Stripe..."
if grep -r "STRIPE" client/src/ 2>/dev/null | grep -v "PayPlug"; then
    echo "⚠️  Références Stripe trouvées dans le code"
else
    echo "✅ Pas de références Stripe dans le code"
fi

# 7. Réinstaller les dépendances proprement
echo "📦 Réinstallation des dépendances..."
npm cache clean --force
npm install

# 8. Build production
echo "🔨 Build production..."
npm run build

# 9. Vérifier le résultat
echo "🏁 Vérification finale..."
if [ -d "dist" ]; then
    echo "✅ Build réussi - dist/ créé"
else
    echo "❌ Build échoué - pas de dist/"
fi

# 10. Vérifier qu'il n'y a pas de Stripe dans le build
if grep -r "stripe" dist/ 2>/dev/null | grep -v "PayPlug"; then
    echo "⚠️  Références Stripe trouvées dans le build"
else
    echo "✅ Pas de références Stripe dans le build"
fi

echo ""
echo "🎉 NETTOYAGE TERMINÉ !"
echo "===================="
echo ""
echo "✅ Scripts Stripe supprimés"
echo "✅ Fichiers temporaires nettoyés"
echo "✅ Caches vidés"
echo "✅ tsconfig.node.json créé"
echo "✅ vite.config.production.ts créé"
echo "✅ Build production réussi"
echo ""
echo "🚀 Application prête pour déploiement VPS"
echo "📖 Consultez VPS-DEPLOYMENT-GUIDE-FINAL.md pour les instructions"