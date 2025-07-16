#!/bin/bash

echo "⚡ QUICK NGINX ASSETS FIX"
echo "========================"

# 1. Permissions
sudo chown -R www-data:www-data dist/
sudo chmod -R 755 dist/

# 2. Configuration simple
cat > /tmp/nginx-quick.conf << 'EOF'
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
    
    # ASSETS DIRECT
    location /assets/ {
        alias /home/ubuntu/JobDone/dist/assets/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Content-Type "application/javascript; charset=utf-8";
        try_files $uri =404;
    }
    
    # CSS DIRECT
    location ~* \.css$ {
        root /home/ubuntu/JobDone/dist;
        expires 1y;
        add_header Content-Type "text/css; charset=utf-8";
        try_files $uri =404;
    }
    
    # JS DIRECT
    location ~* \.js$ {
        root /home/ubuntu/JobDone/dist;
        expires 1y;
        add_header Content-Type "application/javascript; charset=utf-8";
        try_files $uri =404;
    }
    
    # API
    location /api/ {
        proxy_pass http://localhost:5000/api/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
    
    # APP
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
EOF

# 3. Appliquer
sudo cp /tmp/nginx-quick.conf /etc/nginx/sites-available/bennespro

# 4. Recharger
sudo nginx -t && sudo systemctl reload nginx

# 5. Test
echo "🧪 Test:"
curl -s -I https://purpleguy.world/assets/index-BGktlCn_.js | head -2

echo "✅ DONE"