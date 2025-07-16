#!/bin/bash

echo "🔧 NGINX STATIC FILES FIX"
echo "========================="

# 1. Vérifier les fichiers assets
echo "📁 Vérification des fichiers assets..."
ls -la dist/assets/ | head -10
echo "Permissions dist:"
ls -la dist/

# 2. Corriger les permissions
echo "🔐 Correction des permissions..."
sudo chown -R www-data:www-data dist/
sudo chmod -R 755 dist/

# 3. Configuration nginx complète
echo "🔧 Configuration nginx complète..."
cat > /tmp/nginx-static-fix.conf << EOF
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
    
    # CSP corrigé
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; connect-src 'self' wss://purpleguy.world ws://purpleguy.world; img-src 'self' data: https:; font-src 'self'; worker-src 'self' blob:;" always;
    
    client_max_body_size 50M;
    
    # SERVIR FICHIERS STATIQUES DIRECTEMENT
    location /assets/ {
        alias $(pwd)/dist/assets/;
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
        location ~* \.(woff|woff2|ttf|eot)\$ {
            add_header Content-Type "font/woff2";
        }
        
        try_files \$uri =404;
    }
    
    # Favicon
    location = /favicon.ico {
        alias $(pwd)/dist/favicon.ico;
        expires 1y;
        add_header Cache-Control "public, immutable";
        log_not_found off;
        access_log off;
    }
    
    # Autres fichiers statiques
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)\$ {
        root $(pwd)/dist;
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
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
echo "💾 Sauvegarde et application..."
sudo cp /etc/nginx/sites-available/bennespro /etc/nginx/sites-available/bennespro.backup.$(date +%s)
sudo cp /tmp/nginx-static-fix.conf /etc/nginx/sites-available/bennespro

# 5. Test et rechargement
echo "🧪 Test nginx..."
if sudo nginx -t; then
    echo "✅ Configuration valide"
    sudo systemctl reload nginx
    echo "✅ Nginx rechargé"
else
    echo "❌ Erreur configuration"
    sudo nginx -t
    exit 1
fi

# 6. Test des fichiers
echo ""
echo "🧪 Test des fichiers statiques..."
sleep 3

echo "Test CSS direct:"
curl -s -I https://purpleguy.world/assets/index-BEb0iJbV.css | grep -E "(HTTP|content-type)"

echo "Test JS direct:"
curl -s -I https://purpleguy.world/assets/index-BGktlCn_.js | grep -E "(HTTP|content-type)"

echo "Test contenu JS (premiers caractères):"
curl -s https://purpleguy.world/assets/index-BGktlCn_.js | head -c 50

# 7. Vérifier nginx logs
echo ""
echo "📋 Logs nginx récents:"
sudo tail -5 /var/log/nginx/error.log 2>/dev/null || echo "Pas de logs d'erreur"

# 8. Résumé
echo ""
echo "✅ NGINX STATIC FILES CONFIGURÉ"
echo "🌐 Testez https://purpleguy.world"
echo "📊 Status:"
echo "- PM2: $(pm2 list 2>/dev/null | grep -c online) processus online"
echo "- Port 5000: $(ss -tlnp | grep -c ':5000' 2>/dev/null || echo '0')"
echo "- Nginx: $(systemctl is-active nginx 2>/dev/null || echo 'inactive')"