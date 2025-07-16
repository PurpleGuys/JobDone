#!/bin/bash

echo "🔧 FIX IMMEDIATE VPS"
echo "==================="

# 1. Diagnostic rapide
echo "📊 Status actuel:"
echo "PM2: $(pm2 list 2>/dev/null | grep -c online) processus"
echo "Port 5000: $(netstat -tlnp 2>/dev/null | grep -c ':5000')"

# 2. Redémarrer PM2 avec le bon port
echo ""
echo "🚀 Redémarrage PM2 sur port 5000..."
pm2 stop all
pm2 delete all

# 3. Vérifier l'ecosystem config
if [ -f "ecosystem.config.cjs" ]; then
    echo "📝 Utilisation ecosystem.config.cjs"
    # Vérifier le contenu
    cat ecosystem.config.cjs
    pm2 start ecosystem.config.cjs --env production
else
    echo "📝 Création ecosystem.config.cjs"
    cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'bennespro',
    script: 'tsx',
    args: 'server/index.ts',
    env: {
      NODE_ENV: 'production',
      PORT: '5000'
    },
    instances: 1,
    exec_mode: 'fork',
    watch: false,
    max_memory_restart: '1G'
  }]
}
EOF
    pm2 start ecosystem.config.cjs --env production
fi

# 4. Attendre et vérifier
echo ""
echo "⏳ Attente 10 secondes..."
sleep 10

# 5. Vérifier le port 5000
echo "🔍 Vérification port 5000:"
netstat -tlnp | grep ":5000" || echo "❌ Pas de processus sur port 5000"

# 6. Si pas de port 5000, forcer le démarrage
if ! netstat -tlnp | grep -q ":5000"; then
    echo "🔄 Démarrage forcé sur port 5000..."
    pm2 stop all
    pm2 delete all
    
    # Essayer différentes méthodes
    echo "Méthode 1: tsx avec PORT=5000"
    PORT=5000 pm2 start "tsx server/index.ts" --name bennespro
    sleep 3
    
    if ! netstat -tlnp | grep -q ":5000"; then
        echo "Méthode 2: Direct avec --env"
        pm2 start "tsx server/index.ts" --name bennespro --env production -i 1
        sleep 3
    fi
fi

# 7. Configuration nginx pour fichiers statiques
echo ""
echo "🔧 Configuration nginx pour fichiers statiques..."
cat > /tmp/nginx-fix.conf << EOF
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
    
    # SERVIR FICHIERS STATIQUES DIRECTEMENT
    location /assets/ {
        alias $(pwd)/dist/assets/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }
    
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)\$ {
        root $(pwd)/dist;
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

# 8. Appliquer nginx
sudo cp /tmp/nginx-fix.conf /etc/nginx/sites-available/bennespro
sudo nginx -t && sudo systemctl reload nginx

# 9. Test final
echo ""
echo "🧪 Test final:"
echo "PM2 Status:"
pm2 list
echo ""
echo "Port 5000:"
netstat -tlnp | grep ":5000"
echo ""
echo "Test connexion:"
curl -s -I http://localhost:5000 | head -3
echo ""
echo "Test site:"
curl -s -I https://purpleguy.world | head -3

# 10. Logs PM2 si problème
if ! netstat -tlnp | grep -q ":5000"; then
    echo ""
    echo "❌ PROBLÈME PERSISTANT"
    echo "Logs PM2:"
    pm2 logs --lines 20
else
    echo ""
    echo "✅ FIXE!"
    echo "🌐 Testez https://purpleguy.world"
fi