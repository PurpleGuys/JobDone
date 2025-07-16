#!/bin/bash

echo "🚀 VPS SOLUTION COMPLÈTE"
echo "========================"

# 1. Localiser l'application
echo "🔍 Localisation de l'application..."
APP_DIR=""
if [ -f "server/index.ts" ]; then
    APP_DIR=$(pwd)
elif [ -f "../server/index.ts" ]; then
    APP_DIR=$(cd .. && pwd)
elif [ -f "/home/ubuntu/BennesPro/server/index.ts" ]; then
    APP_DIR="/home/ubuntu/BennesPro"
elif [ -f "/home/ubuntu/JobDone/server/index.ts" ]; then
    APP_DIR="/home/ubuntu/JobDone"
else
    echo "❌ Application introuvable"
    exit 1
fi

echo "✅ Application trouvée dans: $APP_DIR"
cd "$APP_DIR"

# 2. Build de l'application
echo ""
echo "🔨 Build de l'application..."
if [ -f "package.json" ]; then
    npm run build
    if [ -d "dist" ]; then
        echo "✅ Build réussi"
    else
        echo "❌ Build échoué"
        exit 1
    fi
else
    echo "❌ Pas de package.json"
    exit 1
fi

# 3. Configuration nginx COMPLÈTE
echo ""
echo "🔧 Configuration nginx complète..."
cat > /tmp/nginx-complete.conf << EOF
server {
    listen 80;
    listen [::]:80;
    server_name purpleguy.world www.purpleguy.world;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;
    server_name purpleguy.world www.purpleguy.world;

    # SSL
    ssl_certificate /etc/letsencrypt/live/purpleguy.world/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/purpleguy.world/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    
    # Headers sécurité
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # CSP corrigé pour WebSocket
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' wss://purpleguy.world ws://purpleguy.world; worker-src 'self' blob:;" always;
    
    client_max_body_size 50M;
    
    # SERVIR LES FICHIERS STATIQUES DIRECTEMENT
    location /assets/ {
        alias $APP_DIR/dist/assets/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Access-Control-Allow-Origin "*";
        
        # Types MIME explicites
        location ~* \.js\$ {
            add_header Content-Type "application/javascript; charset=utf-8";
        }
        location ~* \.css\$ {
            add_header Content-Type "text/css; charset=utf-8";
        }
        location ~* \.(png|jpg|jpeg|gif|ico)\$ {
            add_header Content-Type "image/jpeg";
        }
        location ~* \.svg\$ {
            add_header Content-Type "image/svg+xml";
        }
        location ~* \.(woff|woff2)\$ {
            add_header Content-Type "font/woff2";
        }
        
        try_files \$uri =404;
    }
    
    # Autres fichiers statiques
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)\$ {
        root $APP_DIR/dist;
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }
    
    # Favicon spécifique
    location = /favicon.ico {
        root $APP_DIR/dist;
        expires 1y;
        add_header Cache-Control "public, immutable";
        log_not_found off;
        access_log off;
    }
    
    # API routes
    location /api/ {
        proxy_pass http://localhost:5000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # WebSocket
    location /ws/ {
        proxy_pass http://localhost:5000/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_read_timeout 86400;
    }
    
    # Application React
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# 4. Backup et application
echo "💾 Sauvegarde configuration actuelle..."
sudo cp /etc/nginx/sites-available/bennespro /etc/nginx/sites-available/bennespro.backup.$(date +%s) 2>/dev/null || true

echo "📝 Application nouvelle configuration..."
sudo cp /tmp/nginx-complete.conf /etc/nginx/sites-available/bennespro

# 5. Test et rechargement
echo ""
echo "🧪 Test configuration nginx..."
if sudo nginx -t; then
    echo "✅ Configuration valide"
    sudo systemctl reload nginx
    echo "✅ Nginx rechargé"
else
    echo "❌ Erreur configuration nginx"
    exit 1
fi

# 6. Vérifier PM2
echo ""
echo "🚀 Vérification PM2..."
if ! pm2 list | grep -q "online"; then
    echo "Démarrage PM2..."
    if [ -f "ecosystem.config.cjs" ]; then
        pm2 start ecosystem.config.cjs --env production
    else
        pm2 start "tsx server/index.ts" --name bennespro --env production
    fi
    sleep 3
fi

# 7. Définir les permissions
echo ""
echo "🔐 Configuration des permissions..."
sudo chown -R www-data:www-data $APP_DIR/dist 2>/dev/null || true
sudo chmod -R 755 $APP_DIR/dist 2>/dev/null || true

# 8. Test final
echo ""
echo "🧪 Test final des URLs..."
sleep 5

echo "Test CSS:"
curl -s -I https://purpleguy.world/assets/index-BEb0iJbV.css | grep -i content-type || echo "CSS non trouvé"

echo "Test JS:"
curl -s -I https://purpleguy.world/assets/index-BGktlCn_.js | grep -i content-type || echo "JS non trouvé"

echo "Test contenu JS:"
curl -s https://purpleguy.world/assets/index-BGktlCn_.js | head -c 50 || echo "Contenu JS indisponible"

# 9. Résumé
echo ""
echo "✅ SOLUTION APPLIQUÉE"
echo "====================="
echo "📁 Application: $APP_DIR"
echo "🔨 Build: $([ -d "$APP_DIR/dist" ] && echo 'OK' || echo 'KO')"
echo "🚀 PM2: $(pm2 list 2>/dev/null | grep -c online || echo '0') processus"
echo "🔧 Nginx: $(systemctl is-active nginx 2>/dev/null || echo 'inactive')"
echo ""
echo "🌐 Testez https://purpleguy.world"
echo "📋 Logs: pm2 logs"