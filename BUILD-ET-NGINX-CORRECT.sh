#!/bin/bash

echo "🔨 BUILD ET NGINX CORRECT"
echo "========================="

# 1. Aller dans le bon dossier
cd /home/ubuntu/JobDone

# 2. Build forcé
echo "🔨 Build forcé..."
npm run build

# 3. Vérifier les fichiers créés
echo "📁 Vérification des fichiers créés:"
ls -la dist/assets/ 2>/dev/null || echo "❌ Pas d'assets"

# 4. Trouver les vrais noms de fichiers
echo "🔍 Recherche des vrais noms de fichiers:"
JS_FILE=$(find dist/assets -name "*.js" | head -1)
CSS_FILE=$(find dist/assets -name "*.css" | head -1)

echo "JS file: $JS_FILE"
echo "CSS file: $CSS_FILE"

# 5. Corriger les permissions
echo "🔐 Correction des permissions..."
sudo chown -R www-data:www-data dist/
sudo chmod -R 755 dist/

# 6. Configuration nginx avec les vrais chemins
echo "🔧 Configuration nginx avec vrais chemins..."
cat > /tmp/nginx-correct.conf << EOF
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

    ssl_certificate /etc/letsencrypt/live/purpleguy.world/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/purpleguy.world/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    
    add_header Strict-Transport-Security "max-age=31536000" always;
    client_max_body_size 50M;
    
    # Assets avec chemins réels
    location /assets/ {
        alias /home/ubuntu/JobDone/dist/assets/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # Forcer les types MIME
        location ~* \.js\$ {
            add_header Content-Type "application/javascript; charset=utf-8";
        }
        location ~* \.css\$ {
            add_header Content-Type "text/css; charset=utf-8";
        }
        
        try_files \$uri =404;
    }
    
    # Servir tous les fichiers statiques
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)\$ {
        root /home/ubuntu/JobDone/dist;
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # Types MIME explicites
        location ~* \.js\$ {
            add_header Content-Type "application/javascript; charset=utf-8";
        }
        location ~* \.css\$ {
            add_header Content-Type "text/css; charset=utf-8";
        }
        
        try_files \$uri =404;
    }
    
    # API
    location /api/ {
        proxy_pass http://localhost:5000/api/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
    
    # Application
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
EOF

# 7. Appliquer la configuration
sudo cp /tmp/nginx-correct.conf /etc/nginx/sites-available/bennespro

# 8. Tester et recharger
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Nginx rechargé"
else
    echo "❌ Erreur nginx"
    sudo nginx -t
fi

# 9. Test immédiat des fichiers trouvés
echo ""
echo "🧪 Test des fichiers trouvés:"
if [ -n "$JS_FILE" ]; then
    BASENAME_JS=$(basename "$JS_FILE")
    echo "Test JS: $BASENAME_JS"
    curl -s -I "https://purpleguy.world/assets/$BASENAME_JS" | head -2
fi

if [ -n "$CSS_FILE" ]; then
    BASENAME_CSS=$(basename "$CSS_FILE")
    echo "Test CSS: $BASENAME_CSS"
    curl -s -I "https://purpleguy.world/assets/$BASENAME_CSS" | head -2
fi

echo ""
echo "✅ BUILD ET NGINX APPLIQUÉS"
echo "🌐 Testez https://purpleguy.world"