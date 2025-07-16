#!/bin/bash

echo "🔧 APPLICATION NGINX MIME FORCE"
echo "==============================="

# 1. Backup config actuelle
sudo cp /etc/nginx/sites-available/bennespro /etc/nginx/sites-available/bennespro.backup.force

# 2. Appliquer la nouvelle config
sudo cp nginx-mime-force.conf /etc/nginx/sites-available/bennespro

# 3. Tester
echo "🧪 Test configuration nginx:"
if sudo nginx -t; then
    echo "✅ Configuration valide"
    sudo systemctl reload nginx
    echo "✅ Nginx rechargé"
else
    echo "❌ Erreur configuration"
    sudo cp /etc/nginx/sites-available/bennespro.backup.force /etc/nginx/sites-available/bennespro
    exit 1
fi

# 4. Attendre et tester
echo ""
echo "⏳ Attente 5 secondes..."
sleep 5

echo "🧪 Test des types MIME:"
echo "CSS:"
curl -s -I https://purpleguy.world/assets/index-BEb0iJbV.css | grep -i content-type

echo "JS:"
curl -s -I https://purpleguy.world/assets/index-BGktlCn_.js | grep -i content-type

echo ""
echo "✅ MIME FORCE APPLIQUÉ"
echo "🌐 Testez https://purpleguy.world"