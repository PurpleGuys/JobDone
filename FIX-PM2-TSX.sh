#!/bin/bash

echo "🔧 FIX PM2 TSX - CORRECTION IMMÉDIATE"
echo "===================================="

# 1. INSTALLER TSX GLOBALEMENT
echo "📦 Installation TSX global..."
sudo npm install -g tsx typescript

# Vérifier installation
echo "✅ TSX installé: $(which tsx)"

# 2. NETTOYER PM2
echo "🧹 Nettoyage PM2..."
pm2 kill
pm2 flush

# 3. TROUVER L'APPLICATION
APP_DIR=""
DIRS=(
    "/home/$(whoami)/BennesPro"
    "/var/www/html/BennesPro"
    "/opt/BennesPro"
    "$(pwd)"
)

for dir in "${DIRS[@]}"; do
    if [[ -f "$dir/package.json" ]]; then
        APP_DIR="$dir"
        break
    fi
done

if [[ -z "$APP_DIR" ]]; then
    echo "❌ Application non trouvée!"
    exit 1
fi

echo "✅ Application: $APP_DIR"
cd "$APP_DIR"

# 4. BUILD L'APPLICATION
echo "🔨 Build application..."
npm run build || {
    echo "⚠️  Build échoué, on continue..."
    # Créer dist/index.js si nécessaire
    if [[ ! -f "dist/index.js" && -f "server/index.ts" ]]; then
        echo "📝 Compilation TypeScript..."
        npx tsc server/index.ts --outDir dist --esModuleInterop --module commonjs --target es2020
    fi
}

# 5. DÉMARRER AVEC PM2 - MÉTHODE SIMPLE
echo "🚀 Démarrage PM2 (méthode simple)..."

# Option 1: Si dist/index.js existe (après build)
if [[ -f "dist/index.js" ]]; then
    echo "✅ Utilisation du build compilé"
    pm2 start dist/index.js \
        --name bennespro \
        --instances max \
        --exec-mode cluster \
        --env NODE_ENV=production \
        --env PORT=5000 \
        --log logs/pm2.log \
        --time
        
# Option 2: Si server/index.js existe
elif [[ -f "server/index.js" ]]; then
    echo "✅ Utilisation de server/index.js"
    pm2 start server/index.js \
        --name bennespro \
        --instances max \
        --exec-mode cluster \
        --env NODE_ENV=production \
        --env PORT=5000 \
        --log logs/pm2.log \
        --time
        
# Option 3: Utiliser tsx directement
else
    echo "✅ Utilisation de tsx avec server/index.ts"
    pm2 start server/index.ts \
        --name bennespro \
        --interpreter $(which tsx) \
        --instances 1 \
        --env NODE_ENV=production \
        --env PORT=5000 \
        --log logs/pm2.log \
        --time
fi

# 6. SAUVEGARDER
echo "💾 Sauvegarde configuration..."
pm2 save --force

# 7. TEST
sleep 5
echo ""
echo "🧪 VÉRIFICATION:"
echo "==============="
pm2 list

# Test API
if curl -s http://localhost:5000/api/health | grep -q "ok"; then
    echo "✅ API accessible"
else
    echo "❌ API non accessible"
    echo "📋 Logs PM2:"
    pm2 logs --lines 20
fi

echo ""
echo "✅ FIX TERMINÉ!"
echo "=============="
echo "Si ça ne marche toujours pas, essayez:"
echo "1. pm2 logs --err"
echo "2. cd $APP_DIR && node dist/index.js (test manuel)"