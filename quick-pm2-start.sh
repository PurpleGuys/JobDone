#!/bin/bash

echo "⚡ DÉMARRAGE RAPIDE PM2"
echo "====================="

# 1. Créer ecosystem.config.cjs si manquant
if [ ! -f "ecosystem.config.cjs" ]; then
    echo "📄 Création ecosystem.config.cjs..."
    cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'bennespro',
    script: 'tsx',
    args: 'server/index.ts',
    env: {
      NODE_ENV: 'production',
      PORT: '5000'
    }
  }]
}
EOF
fi

# 2. Installer tsx globalement
npm install -g tsx 2>/dev/null || true

# 3. Démarrer directement avec PM2
echo "🚀 Démarrage PM2..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Si server/index.ts existe
if [ -f "server/index.ts" ]; then
    pm2 start ecosystem.config.cjs --env production
else
    echo "❌ server/index.ts introuvable"
    echo "Tentative de démarrage avec différents chemins..."
    
    # Essayer différents chemins
    if [ -f "../server/index.ts" ]; then
        cd ..
        pm2 start ecosystem.config.cjs --env production
    elif [ -f "index.ts" ]; then
        pm2 start "tsx index.ts" --name bennespro --env production
    else
        echo "❌ Impossible de trouver le serveur"
        exit 1
    fi
fi

# 4. Vérifier
sleep 3
echo "📊 Status:"
pm2 list

# 5. Test rapide
if curl -s http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ OK - Application démarrée!"
else
    echo "❌ Problème - Vérifiez les logs:"
    pm2 logs --lines 5
fi