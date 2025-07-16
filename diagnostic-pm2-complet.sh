#!/bin/bash

echo "🔍 DIAGNOSTIC PM2 & APPLICATION"
echo "==============================="

# 1. Vérifier PM2
echo "📊 Status PM2:"
if command -v pm2 &> /dev/null; then
    echo "✅ PM2 installé"
    pm2 list
    echo ""
    pm2 logs --lines 10
else
    echo "❌ PM2 non installé"
    echo "Installation PM2..."
    npm install -g pm2
fi

# 2. Vérifier si l'application tourne sur port 5000
echo ""
echo "🔍 Vérification port 5000:"
if netstat -tlnp 2>/dev/null | grep -q ":5000"; then
    echo "✅ Application écoute sur port 5000"
    netstat -tlnp | grep ":5000"
else
    echo "❌ Aucune application sur port 5000"
    echo "Processus qui écoutent:"
    netstat -tlnp | grep LISTEN
fi

# 3. Vérifier les fichiers BennesPro
echo ""
echo "📁 Vérification fichiers BennesPro:"
if [ -f "/home/ubuntu/BennesPro/server/index.ts" ]; then
    echo "✅ Fichier serveur trouvé"
    ls -la /home/ubuntu/BennesPro/server/
else
    echo "❌ Fichier serveur introuvable"
    echo "Contenu du dossier BennesPro:"
    ls -la /home/ubuntu/BennesPro/ 2>/dev/null || echo "Dossier BennesPro introuvable"
fi

# 4. Vérifier Node.js et tsx
echo ""
echo "🔧 Vérification Node.js:"
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"
if command -v tsx &> /dev/null; then
    echo "✅ tsx installé"
else
    echo "❌ tsx non installé"
fi

# 5. Vérifier les logs nginx
echo ""
echo "📋 Logs nginx récents:"
sudo tail -10 /var/log/nginx/error.log 2>/dev/null || echo "Pas de logs nginx"

# 6. Test connexion locale
echo ""
echo "🌐 Test connexion locale:"
if curl -s http://localhost:5000 > /dev/null; then
    echo "✅ Application répond en local"
else
    echo "❌ Application ne répond pas en local"
fi

echo ""
echo "🎯 RÉSUMÉ:"
echo "========="
echo "1. PM2 status: $(pm2 list 2>/dev/null | grep -c "online" || echo "0") processus online"
echo "2. Port 5000: $(netstat -tlnp 2>/dev/null | grep -c ":5000" || echo "0") processus"
echo "3. Nginx: $(systemctl is-active nginx)"
echo "4. Solution: Démarrer PM2 avec l'application"