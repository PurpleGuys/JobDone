#!/bin/bash

echo "🔍 RECHERCHE APPLICATION BENNESPRO"
echo "=================================="

# 1. Vérifier le dossier actuel
echo "📁 Dossier actuel: $(pwd)"
echo "Contenu:"
ls -la

# 2. Chercher les fichiers BennesPro
echo ""
echo "🔍 Recherche des fichiers BennesPro..."

# Chercher server/index.ts
if [ -f "server/index.ts" ]; then
    echo "✅ server/index.ts trouvé dans le dossier actuel"
    FOUND_PATH="$(pwd)"
elif [ -f "../server/index.ts" ]; then
    echo "✅ server/index.ts trouvé dans le dossier parent"
    FOUND_PATH="$(cd .. && pwd)"
elif [ -f "/home/ubuntu/BennesPro/server/index.ts" ]; then
    echo "✅ server/index.ts trouvé dans /home/ubuntu/BennesPro"
    FOUND_PATH="/home/ubuntu/BennesPro"
else
    echo "❌ server/index.ts introuvable"
    echo "Recherche dans tout le système..."
    find /home -name "index.ts" -path "*/server/*" 2>/dev/null | head -5
fi

# 3. Vérifier ecosystem.config.cjs
echo ""
echo "🔍 Recherche ecosystem.config.cjs..."
if [ -f "ecosystem.config.cjs" ]; then
    echo "✅ ecosystem.config.cjs trouvé"
    echo "Contenu:"
    cat ecosystem.config.cjs
else
    echo "❌ ecosystem.config.cjs introuvable"
    echo "Recherche..."
    find . -name "ecosystem.config.cjs" 2>/dev/null
fi

# 4. Vérifier package.json
echo ""
echo "🔍 Recherche package.json..."
if [ -f "package.json" ]; then
    echo "✅ package.json trouvé"
    echo "Scripts disponibles:"
    cat package.json | grep -A 10 '"scripts"'
else
    echo "❌ package.json introuvable"
fi

# 5. Résumé
echo ""
echo "📋 RÉSUMÉ:"
echo "========="
if [ -n "$FOUND_PATH" ]; then
    echo "Application trouvée dans: $FOUND_PATH"
    echo "Utilisation: cd $FOUND_PATH && pm2 start ecosystem.config.cjs"
else
    echo "Application non trouvée"
    echo "Vérifiez que vous êtes dans le bon dossier"
fi