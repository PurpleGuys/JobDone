#!/bin/bash

echo "🔧 FIX 502 BAD GATEWAY"
echo "====================="

# 1. Diagnostic rapide
echo "🔍 Diagnostic rapide..."
PM2_STATUS=$(pm2 list 2>/dev/null | grep -c "online" || echo "0")
PORT_5000=$(netstat -tlnp 2>/dev/null | grep -c ":5000" || echo "0")

echo "PM2 processus online: $PM2_STATUS"
echo "Applications sur port 5000: $PORT_5000"

# 2. Si PM2 n'est pas en cours
if [ "$PM2_STATUS" -eq 0 ]; then
    echo "❌ PM2 n'est pas en cours d'exécution"
    echo "🚀 Démarrage de l'application..."
    
    cd /home/ubuntu/BennesPro || {
        echo "❌ Dossier BennesPro introuvable"
        exit 1
    }
    
    # Démarrer avec PM2
    pm2 start ecosystem.config.cjs --env production
    sleep 5
    
    # Vérifier
    if pm2 list | grep -q "online"; then
        echo "✅ PM2 démarré avec succès"
    else
        echo "❌ Échec démarrage PM2"
        echo "📋 Logs PM2:"
        pm2 logs --lines 10
    fi
fi

# 3. Si port 5000 n'est pas occupé
if [ "$PORT_5000" -eq 0 ]; then
    echo "❌ Aucune application sur port 5000"
    echo "🔄 Tentative de démarrage manuel..."
    
    cd /home/ubuntu/BennesPro
    
    # Essayer différentes méthodes
    echo "Méthode 1: PM2 avec tsx"
    pm2 start "tsx server/index.ts" --name "bennespro" --env production
    sleep 3
    
    if ! netstat -tlnp | grep -q ":5000"; then
        echo "Méthode 2: Node.js direct"
        pm2 start "node server/index.js" --name "bennespro-node" --env production
        sleep 3
    fi
    
    if ! netstat -tlnp | grep -q ":5000"; then
        echo "Méthode 3: NPM start"
        pm2 start "npm start" --name "bennespro-npm" --env production
        sleep 3
    fi
fi

# 4. Test final
echo ""
echo "🧪 Test final..."
sleep 2

if curl -s http://localhost:5000/api/health > /dev/null; then
    echo "✅ Application répond!"
    echo "🌐 Testez https://purpleguy.world"
    
    # Redémarrer nginx pour s'assurer
    sudo systemctl reload nginx
    
    echo "✅ 502 Bad Gateway corrigé!"
else
    echo "❌ Application ne répond toujours pas"
    echo ""
    echo "📋 Diagnostic approfondi:"
    echo "PM2 Status:"
    pm2 list
    echo ""
    echo "Logs récents:"
    pm2 logs --lines 20
    echo ""
    echo "Processus sur port 5000:"
    netstat -tlnp | grep ":5000"
    echo ""
    echo "Solution: Vérifiez les logs et redémarrez manuellement"
fi