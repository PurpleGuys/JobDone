#!/bin/bash

echo "🚨 URGENT PM2 FIX"
echo "=================="

# 1. Arrêter complètement PM2
echo "⏹️ Arrêt PM2..."
pm2 stop all
pm2 delete all

# 2. Vérifier le serveur
echo "🔍 Vérification serveur..."
if [ -f "server/index.ts" ]; then
    echo "✅ server/index.ts trouvé"
else
    echo "❌ server/index.ts introuvable"
    ls -la server/
    exit 1
fi

# 3. Lancer avec PORT explicite
echo "🚀 Lancement avec PORT=5000..."
PORT=5000 NODE_ENV=production pm2 start "tsx server/index.ts" --name bennespro --watch false

# 4. Attendre
echo "⏳ Attente 5 secondes..."
sleep 5

# 5. Vérifier
echo "🔍 Vérification port 5000:"
netstat -tlnp | grep ":5000"

if netstat -tlnp | grep -q ":5000"; then
    echo "✅ Port 5000 OK"
else
    echo "❌ Port 5000 KO - Retry"
    pm2 stop all
    pm2 delete all
    
    # Essai avec ts-node
    echo "Essai avec ts-node..."
    PORT=5000 pm2 start "ts-node server/index.ts" --name bennespro --watch false
    sleep 3
    
    if ! netstat -tlnp | grep -q ":5000"; then
        echo "Essai avec node..."
        PORT=5000 pm2 start "node server/index.js" --name bennespro --watch false
        sleep 3
    fi
fi

# 6. Status final
echo ""
echo "📊 Status final:"
pm2 list
echo ""
echo "🌐 Port 5000:"
netstat -tlnp | grep ":5000" || echo "❌ Pas de port 5000"

# 7. Si toujours rien, logs
if ! netstat -tlnp | grep -q ":5000"; then
    echo ""
    echo "❌ ÉCHEC - Logs PM2:"
    pm2 logs --lines 10
else
    echo ""
    echo "✅ SUCCÈS!"
fi