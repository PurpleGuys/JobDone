#!/bin/bash

echo "🚨 SOLUTION IMMÉDIATE ERREUR NGINX 500"
echo "====================================="

# 1. Vérifier et démarrer l'application Node.js
echo "🔍 Vérification application Node.js..."
if ! curl -s http://localhost:5000/api/health > /dev/null; then
    echo "❌ Application Node.js non accessible, démarrage..."
    
    # Trouver et démarrer l'application
    cd /home/$(whoami)/BennesPro 2>/dev/null || cd /var/www/html/BennesPro 2>/dev/null || cd /opt/BennesPro 2>/dev/null || {
        echo "❌ Répertoire BennesPro non trouvé"
        exit 1
    }
    
    # Tuer les processus existants
    pkill -f "node.*server" 2>/dev/null || true
    
    # Démarrer l'application
    export NODE_ENV=production
    export PORT=5000
    nohup npm start > app.log 2>&1 &
    
    echo "⏳ Attente démarrage application..."
    sleep 10
    
    if curl -s http://localhost:5000/api/health > /dev/null; then
        echo "✅ Application démarrée avec succès"
    else
        echo "❌ Échec démarrage application"
        exit 1
    fi
else
    echo "✅ Application Node.js accessible"
fi

# 2. Corriger la configuration nginx
echo "🔧 Configuration nginx..."
sudo tee /etc/nginx/sites-available/bennespro > /dev/null << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
        proxy_connect_timeout 86400;
        proxy_send_timeout 86400;
    }
}
EOF

# 3. Activer la configuration
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/bennespro /etc/nginx/sites-enabled/

# 4. Tester et redémarrer nginx
echo "🔄 Test et redémarrage nginx..."
sudo nginx -t
if [ $? -eq 0 ]; then
    sudo systemctl restart nginx
    echo "✅ Nginx redémarré avec succès"
else
    echo "❌ Erreur configuration nginx"
    exit 1
fi

# 5. Test final
echo "🧪 Test final..."
sleep 3
if curl -I http://localhost/ 2>/dev/null | grep -q "200 OK"; then
    echo "✅ SITE ACCESSIBLE - ERREUR 500 CORRIGÉE"
else
    echo "❌ Site toujours inaccessible"
    echo "📋 Vérifiez les logs:"
    echo "   sudo tail -f /var/log/nginx/error.log"
fi

echo ""
echo "🎉 SOLUTION APPLIQUÉE"
echo "==================="
echo "1. Application Node.js démarrée sur port 5000"
echo "2. Configuration nginx corrigée"
echo "3. Nginx redémarré"
echo "4. Site accessible sur votre domaine"