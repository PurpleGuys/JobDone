#!/bin/bash

echo "🔨 BUILD AND DEPLOY BENNESPRO"
echo "============================="

# 1. Build de l'application
echo "📦 Build de l'application..."
if [ -f "package.json" ]; then
    echo "Installation dépendances..."
    npm install
    
    echo "Build production..."
    npm run build
    
    if [ -d "dist" ]; then
        echo "✅ Build réussi"
        echo "Contenu dist:"
        ls -la dist/
        echo "Fichiers assets:"
        ls -la dist/assets/ 2>/dev/null || echo "Pas de dossier assets"
    else
        echo "❌ Build échoué"
        exit 1
    fi
else
    echo "❌ package.json introuvable"
    exit 1
fi

# 2. Démarrer PM2 si nécessaire
echo ""
echo "🚀 Vérification PM2..."
if ! pm2 list | grep -q "online"; then
    echo "Démarrage PM2..."
    pm2 start "tsx server/index.ts" --name bennespro --env production
    sleep 3
fi

# 3. Créer config nginx optimisée
echo ""
echo "🔧 Configuration nginx optimisée..."
cat > /tmp/nginx-optimized.conf << EOF
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
    add_header X-Content-Type-Options "nosniff" always;
    
    client_max_body_size 50M;
    
    # Servir les fichiers statiques directement
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        root $(pwd)/dist;
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }
    
    # Dossier assets
    location /assets/ {
        alias $(pwd)/dist/assets/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }
    
    # API
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
    
    # Application
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
sudo cp /tmp/nginx-optimized.conf /etc/nginx/sites-available/bennespro

# 5. Tester et recharger
echo ""
echo "🧪 Test et rechargement nginx..."
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Nginx rechargé avec succès"
else
    echo "❌ Erreur configuration nginx"
    exit 1
fi

# 6. Test final
echo ""
echo "🧪 Test final:"
sleep 2
echo "Status PM2:"
pm2 list

echo "Test site:"
curl -s -I https://purpleguy.world | head -3

echo ""
echo "✅ DÉPLOIEMENT TERMINÉ"
echo "🌐 Testez https://purpleguy.world"