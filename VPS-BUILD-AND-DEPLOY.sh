#!/bin/bash

echo "🔨 VPS BUILD AND DEPLOY"
echo "======================="

# 1. Aller dans le dossier BennesPro
cd /home/ubuntu/JobDone || cd /home/ubuntu/BennesPro || {
    echo "❌ Dossier BennesPro introuvable"
    exit 1
}

echo "📁 Dossier: $(pwd)"

# 2. Build de l'application
echo "🔨 Build de l'application..."
npm run build

if [ -d "dist" ]; then
    echo "✅ Build réussi"
    ls -la dist/
else
    echo "❌ Build échoué"
    exit 1
fi

# 3. Configuration nginx pour fichiers statiques
echo "🔧 Configuration nginx pour servir les fichiers statiques..."
cat > /tmp/vps-nginx-static.conf << EOF
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
    
    # Servir les fichiers statiques directement
    location /assets/ {
        alias $(pwd)/dist/assets/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }
    
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
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

# 4. Appliquer la configuration
sudo cp /tmp/vps-nginx-static.conf /etc/nginx/sites-available/bennespro

# 5. Tester et recharger
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Nginx rechargé"
else
    echo "❌ Erreur nginx"
    exit 1
fi

# 6. Vérifier PM2
echo ""
echo "🚀 Vérification PM2..."
if ! pm2 list | grep -q "online"; then
    echo "Redémarrage PM2..."
    pm2 restart all
fi

# 7. Test final
echo ""
echo "🧪 Test final:"
curl -s -I https://purpleguy.world/assets/index-BGktlCn_.js | grep -i content-type
curl -s -I https://purpleguy.world/assets/index-BEb0iJbV.css | grep -i content-type

echo ""
echo "✅ DÉPLOIEMENT TERMINÉ"
echo "🌐 Testez https://purpleguy.world"