#!/bin/bash

echo "🔧 VPS FIX MIME TYPES FINAL"
echo "==========================="

# Configuration nginx qui force les types MIME corrects
cat > /tmp/vps-nginx-mime-fix.conf << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name purpleguy.world www.purpleguy.world;
    return 301 https://$server_name$request_uri;
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
    
    # FORCER LES TYPES MIME POUR ASSETS
    location ~* /assets/.*\.js$ {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        
        # FORCER JavaScript
        proxy_hide_header Content-Type;
        add_header Content-Type "application/javascript; charset=utf-8";
        proxy_buffering off;
    }
    
    location ~* /assets/.*\.css$ {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        
        # FORCER CSS
        proxy_hide_header Content-Type;
        add_header Content-Type "text/css; charset=utf-8";
        proxy_buffering off;
    }
    
    # API routes
    location /api/ {
        proxy_pass http://localhost:5000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Application React
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Appliquer
sudo cp /tmp/vps-nginx-mime-fix.conf /etc/nginx/sites-available/bennespro

# Tester et recharger
if sudo nginx -t; then
    echo "✅ Configuration valide"
    sudo systemctl reload nginx
    echo "✅ Nginx rechargé"
else
    echo "❌ Erreur configuration"
    exit 1
fi

# Test
echo ""
echo "🧪 Test des types MIME:"
sleep 3
curl -s -I https://purpleguy.world/assets/index-BGktlCn_.js | grep -i content-type
curl -s -I https://purpleguy.world/assets/index-BEb0iJbV.css | grep -i content-type

echo ""
echo "✅ MIME TYPES CORRIGÉS"
echo "🌐 Testez https://purpleguy.world"