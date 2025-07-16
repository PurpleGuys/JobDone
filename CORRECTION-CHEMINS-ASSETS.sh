#!/bin/bash

echo "🔧 CORRECTION CHEMINS ASSETS"
echo "============================"

# 1. Diagnostic des vrais chemins
echo "🔍 Localisation des fichiers JS/CSS:"
find /home/ubuntu/JobDone/dist -name "*.js" -o -name "*.css"

echo ""
echo "📂 Contenu dist/public:"
ls -la /home/ubuntu/JobDone/dist/public/

if [ -d "/home/ubuntu/JobDone/dist/public/assets" ]; then
    echo ""
    echo "📂 Contenu dist/public/assets:"
    ls -la /home/ubuntu/JobDone/dist/public/assets/
fi

# 2. Configuration nginx avec le bon chemin
echo ""
echo "🔧 Configuration nginx avec chemins corrects..."
cat > /tmp/nginx-assets-correct.conf << 'EOF'
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
    
    # Assets depuis dist/public/assets/
    location /assets/ {
        alias /home/ubuntu/JobDone/dist/public/assets/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # Types MIME corrects
        location ~* \.js$ {
            add_header Content-Type "application/javascript; charset=utf-8";
        }
        location ~* \.css$ {
            add_header Content-Type "text/css; charset=utf-8";
        }
        
        try_files $uri =404;
    }
    
    # Servir tous les fichiers statiques depuis dist/public/
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        root /home/ubuntu/JobDone/dist/public;
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # Types MIME
        location ~* \.js$ {
            add_header Content-Type "application/javascript; charset=utf-8";
        }
        location ~* \.css$ {
            add_header Content-Type "text/css; charset=utf-8";
        }
        
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
    
    # Application
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

# 3. Appliquer la configuration
sudo cp /tmp/nginx-assets-correct.conf /etc/nginx/sites-available/bennespro

# 4. Tester et recharger
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Nginx rechargé"
else
    echo "❌ Erreur nginx"
    sudo nginx -t
fi

# 5. Test des fichiers trouvés
echo ""
echo "🧪 Test des fichiers dans dist/public/assets:"
if [ -d "/home/ubuntu/JobDone/dist/public/assets" ]; then
    for file in /home/ubuntu/JobDone/dist/public/assets/*.js; do
        if [ -f "$file" ]; then
            basename_file=$(basename "$file")
            echo "Test JS: $basename_file"
            curl -s -I "https://purpleguy.world/assets/$basename_file" | head -2
        fi
    done
    
    for file in /home/ubuntu/JobDone/dist/public/assets/*.css; do
        if [ -f "$file" ]; then
            basename_file=$(basename "$file")
            echo "Test CSS: $basename_file"
            curl -s -I "https://purpleguy.world/assets/$basename_file" | head -2
        fi
    done
fi

echo ""
echo "✅ CORRECTION TERMINÉE"
echo "🌐 Testez https://purpleguy.world"