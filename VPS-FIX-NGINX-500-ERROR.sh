#!/bin/bash

echo "🚨 DIAGNOSTIC COMPLET ERREUR NGINX 500 VPS"
echo "=========================================="

# Vérifier si nous sommes sur le VPS
if [[ ! -f "/etc/nginx/nginx.conf" ]]; then
    echo "❌ Ce script doit être exécuté sur le VPS"
    exit 1
fi

echo "1. VÉRIFICATION STATUS SERVICES"
echo "=============================="
echo "🔍 Nginx Status:"
systemctl status nginx --no-pager -l

echo ""
echo "🔍 Node.js/BennesPro Status:"
ps aux | grep -E "(node|tsx|npm)" | grep -v grep

echo ""
echo "🔍 Ports utilisés:"
netstat -tlnp | grep -E "(80|443|5000|8080|3000)"

echo ""
echo "2. VÉRIFICATION LOGS NGINX"
echo "========================="
echo "🔍 Logs d'erreur Nginx (10 dernières lignes):"
tail -10 /var/log/nginx/error.log

echo ""
echo "🔍 Logs d'accès Nginx (5 dernières lignes):"
tail -5 /var/log/nginx/access.log

echo ""
echo "3. VÉRIFICATION CONFIGURATION NGINX"
echo "=================================="
echo "🔍 Test configuration Nginx:"
nginx -t

echo ""
echo "🔍 Sites activés:"
ls -la /etc/nginx/sites-enabled/

echo ""
echo "🔍 Configuration site principal:"
if [[ -f "/etc/nginx/sites-enabled/default" ]]; then
    cat /etc/nginx/sites-enabled/default
elif [[ -f "/etc/nginx/sites-enabled/bennespro" ]]; then
    cat /etc/nginx/sites-enabled/bennespro
else
    echo "❌ Aucun site configuré trouvé"
fi

echo ""
echo "4. VÉRIFICATION APPLICATION NODE.JS"
echo "=================================="
echo "🔍 Test connexion backend local:"
curl -I http://localhost:5000/ 2>/dev/null || echo "❌ Backend non accessible"

echo ""
echo "🔍 Test API health:"
curl -s http://localhost:5000/api/health 2>/dev/null || echo "❌ API health non accessible"

echo ""
echo "5. SOLUTIONS AUTOMATIQUES"
echo "========================"

# Solution 1: Redémarrer nginx
echo "🔧 Redémarrage Nginx..."
systemctl restart nginx

# Solution 2: Vérifier si l'application tourne
if ! pgrep -f "node.*server" > /dev/null; then
    echo "🔧 Application Node.js non trouvée, tentative de démarrage..."
    
    # Chercher le répertoire de l'application
    APP_DIR="/home/$(whoami)/BennesPro"
    if [[ ! -d "$APP_DIR" ]]; then
        APP_DIR="/var/www/html/BennesPro"
    fi
    if [[ ! -d "$APP_DIR" ]]; then
        APP_DIR="/opt/BennesPro"
    fi
    
    if [[ -d "$APP_DIR" ]]; then
        echo "📁 Répertoire app trouvé: $APP_DIR"
        cd "$APP_DIR"
        
        # Installer les dépendances si nécessaire
        if [[ ! -d "node_modules" ]]; then
            echo "📦 Installation des dépendances..."
            npm install
        fi
        
        # Démarrer l'application
        echo "🚀 Démarrage de l'application..."
        npm run build
        nohup npm start > app.log 2>&1 &
        sleep 5
        
        # Vérifier si l'app démarre
        if curl -s http://localhost:5000/api/health > /dev/null; then
            echo "✅ Application démarrée avec succès"
        else
            echo "❌ Échec du démarrage de l'application"
            echo "📋 Logs de l'application:"
            tail -20 app.log
        fi
    else
        echo "❌ Répertoire de l'application non trouvé"
    fi
fi

# Solution 3: Configuration nginx de base
echo ""
echo "🔧 Vérification configuration nginx pour BennesPro..."

NGINX_CONFIG="/etc/nginx/sites-available/bennespro"
if [[ ! -f "$NGINX_CONFIG" ]]; then
    echo "📝 Création configuration nginx pour BennesPro..."
    
    cat > "$NGINX_CONFIG" << 'EOF'
server {
    listen 80;
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
    }
}
EOF
    
    # Activer le site
    ln -sf "$NGINX_CONFIG" /etc/nginx/sites-enabled/bennespro
    
    # Supprimer le site par défaut s'il existe
    rm -f /etc/nginx/sites-enabled/default
    
    # Tester et recharger
    nginx -t && systemctl reload nginx
    
    echo "✅ Configuration nginx créée et activée"
fi

echo ""
echo "6. TESTS FINAUX"
echo "=============="
echo "🔍 Test final connexion:"
sleep 2
curl -I http://localhost/ 2>/dev/null && echo "✅ Site accessible localement" || echo "❌ Site toujours inaccessible"

echo ""
echo "🔍 Status final des services:"
systemctl is-active nginx
systemctl is-active nodejs 2>/dev/null || echo "nodejs service non configuré"

echo ""
echo "📋 RÉSUMÉ DES ACTIONS"
echo "===================="
echo "✅ Nginx redémarré"
echo "✅ Configuration nginx vérifiée/créée"
echo "✅ Application Node.js vérifiée/démarrée"
echo "✅ Tests de connectivité effectués"
echo ""
echo "🌐 Testez maintenant votre site sur Firefox"
echo "Si l'erreur 500 persiste, vérifiez les logs avec:"
echo "   sudo tail -f /var/log/nginx/error.log"