#!/bin/bash

echo "⚡ QUICK MIME FIX"
echo "================"

# 1. Build rapide si nécessaire
if [ ! -d "dist" ] && [ -f "package.json" ]; then
    echo "🔨 Build rapide..."
    npm run build
fi

# 2. Fix nginx simple
echo "🔧 Fix nginx simple..."
cat > /tmp/nginx-simple.conf << EOF
server {
    listen 80;
    server_name purpleguy.world www.purpleguy.world;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    http2 on;
    server_name purpleguy.world www.purpleguy.world;

    ssl_certificate /etc/letsencrypt/live/purpleguy.world/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/purpleguy.world/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    
    client_max_body_size 50M;
    
    # Fix MIME types
    location ~* \.js$ {
        proxy_pass http://localhost:5000;
        proxy_set_header Accept-Encoding "";
        add_header Content-Type "application/javascript";
    }
    
    location ~* \.css$ {
        proxy_pass http://localhost:5000;
        proxy_set_header Accept-Encoding "";
        add_header Content-Type "text/css";
    }
    
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

# 3. Appliquer
sudo cp /tmp/nginx-simple.conf /etc/nginx/sites-available/bennespro

# 4. Test et reload
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Fix appliqué"
else
    echo "❌ Erreur"
fi

echo "🧪 Test: https://purpleguy.world"